require "json"

module Orion::API
  # Pagination helper for APIs
  # Supports offset/limit and cursor-based pagination
  #
  # Usage:
  #   # In controller
  #   paginator = Orion::API::Paginator.new(
  #     collection: users,
  #     page: params["page"]?.try(&.to_i) || 1,
  #     per_page: 25
  #   )
  #
  #   render json: {
  #     data: paginator.items,
  #     pagination: paginator.meta
  #   }
  class Paginator(T)
    property collection : Array(T)
    property page : Int32
    property per_page : Int32
    property total_count : Int32?

    def initialize(
      @collection : Array(T),
      @page : Int32 = 1,
      @per_page : Int32 = 25,
      @total_count : Int32? = nil
    )
      @page = 1 if @page < 1
      @per_page = 100 if @per_page > 100  # Max limit
    end

    # Get paginated items
    def items : Array(T)
      offset = (@page - 1) * @per_page
      @collection[offset, @per_page]? || [] of T
    end

    # Get pagination metadata
    def meta : Hash(String, Int32 | Bool)
      {
        "current_page"  => @page,
        "per_page"      => @per_page,
        "total_pages"   => total_pages,
        "total_count"   => total,
        "has_next_page" => has_next?,
        "has_prev_page" => has_prev?,
      }
    end

    # Get link headers (RFC 5988)
    def link_headers(base_url : String, params : HTTP::Params = HTTP::Params.new) : String
      links = [] of String

      if has_next?
        next_params = params.dup
        next_params["page"] = next_page.to_s
        links << %(<#{base_url}?#{next_params}>; rel="next")
      end

      if has_prev?
        prev_params = params.dup
        prev_params["page"] = prev_page.to_s
        links << %(<#{base_url}?#{prev_params}>; rel="prev")
      end

      # First and last
      first_params = params.dup
      first_params["page"] = "1"
      links << %(<#{base_url}?#{first_params}>; rel="first")

      last_params = params.dup
      last_params["page"] = total_pages.to_s
      links << %(<#{base_url}?#{last_params}>; rel="last")

      links.join(", ")
    end

    def total : Int32
      @total_count || @collection.size
    end

    def total_pages : Int32
      (total.to_f / @per_page).ceil.to_i
    end

    def next_page : Int32
      @page + 1
    end

    def prev_page : Int32
      @page - 1
    end

    def has_next? : Bool
      @page < total_pages
    end

    def has_prev? : Bool
      @page > 1
    end

    def first_page? : Bool
      @page == 1
    end

    def last_page? : Bool
      @page == total_pages
    end
  end

  # Cursor-based pagination (for infinite scroll, real-time data)
  # More efficient for large datasets
  #
  # Usage:
  #   cursor_paginator = Orion::API::CursorPaginator.new(
  #     collection: posts,
  #     cursor: params["cursor"]?,
  #     limit: 25
  #   )
  #
  #   render json: {
  #     data: cursor_paginator.items,
  #     pagination: cursor_paginator.meta
  #   }
  class CursorPaginator(T)
    property collection : Array(T)
    property cursor : String?
    property limit : Int32

    def initialize(
      @collection : Array(T),
      @cursor : String? = nil,
      @limit : Int32 = 25
    )
      @limit = 100 if @limit > 100
    end

    # Get paginated items
    def items : Array(T)
      if cursor = @cursor
        # Find starting point from cursor
        start_id = decode_cursor(cursor)
        index = @collection.index { |item| item.id >= start_id }
        return [] of T unless index

        @collection[index, @limit]? || [] of T
      else
        # First page
        @collection[0, @limit]? || [] of T
      end
    end

    # Get pagination metadata
    def meta : Hash(String, String | Bool | Int32)
      result = {
        "limit"      => @limit,
        "has_more"   => has_more?,
      }

      if next_cur = next_cursor
        result["next_cursor"] = next_cur
      end

      result
    end

    def has_more? : Bool
      items.size == @limit
    end

    def next_cursor : String?
      return nil unless has_more?
      return nil if items.empty?

      encode_cursor(items.last.id)
    end

    private def encode_cursor(id) : String
      Base64.strict_encode(id.to_s)
    end

    private def decode_cursor(cursor : String) : String
      Base64.decode_string(cursor)
    end
  end

  # Helper module to include in controllers
  module PaginationHelpers
    # Paginate a collection
    def paginate(
      collection,
      page : Int32? = nil,
      per_page : Int32 = 25
    )
      page ||= request.query_params["page"]?.try(&.to_i) || 1

      Paginator.new(
        collection: collection,
        page: page,
        per_page: per_page
      )
    end

    # Cursor paginate a collection
    def cursor_paginate(
      collection,
      cursor : String? = nil,
      limit : Int32 = 25
    )
      cursor ||= request.query_params["cursor"]?

      CursorPaginator.new(
        collection: collection,
        cursor: cursor,
        limit: limit
      )
    end

    # Add Link header to response
    def add_pagination_links(paginator : Paginator, base_url : String)
      response.headers["Link"] = paginator.link_headers(base_url, request.query_params)
    end
  end
end
