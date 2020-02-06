module Simulator

using OnlineStats
using Brokerages: AbstractBrokerage
using Markets: AbstractMarket, is_preopen, is_opening, is_open, is_closing, is_closed
export
    AbstractStrategy,
    initialize!,
    should_run,
    process_preopen!,
    process_open!,
    process!,
    process_close!,
    process_postclose!,
    update_statistics!,
    run!

include("strategy.jl")
include("statistics.jl")

function run!(s::AbstractStrategy, b::AbstractBrokerage, m::AbstractMarket)
    params = initialize!(s, b, m)
    while should_run(s, b, m)
        if is_preopen(m)
            process_preopen!(s, b, m)
        elseif is_opening(m)
            process_open!(s, b, m)
        elseif is_open(m)
            process!(s, b, m)
        elseif is_closing(m)
            process_close!(s, b, m)
        elseif is_closed(m)
            process_postclose!(s, b, m)
        end
        update_statistics!(s, b, m)
    end
end

end # module
