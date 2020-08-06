# :nodoc:
module Orion::View::Registry
  {{ run "./renderer/defs.cr", `date +%s%N` }}

  private def combine_locals(left : Nil, right : NamedTuple)
    right
  end

  private def combine_locals(left : NamedTuple, right : Nil)
    left
  end

  private def combine_locals(left : NamedTuple, right : NamedTuple)
    right.merge(left)
  end

  private def combine_locals(l1, l2, l3)
    combine_locals(l1, combine_locals(l2, l3))
  end
end
