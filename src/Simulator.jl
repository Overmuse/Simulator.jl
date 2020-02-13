module Simulator

using Brokerages: AbstractBrokerage
using Markets:
    AbstractMarket,
    is_preopen,
    is_opening,
    is_open,
    is_closing,
    is_closed,
    reset!
using TradingBase: AbstractMarketDataProvider
export
    AbstractStrategy,
    initialize!,
    should_run,
    process_preopen!,
    process_open!,
    process!,
    process_close!,
    process_postclose!,
    finalize!,
    update_statistics!,
    run!

include("strategy.jl")
include("statistics.jl")

function run!(s::AbstractStrategy, b::AbstractBrokerage, m::AbstractMarketDataProvider)
    #reset!(m)
    params = initialize!(s, b, m)
    while should_run(s, b, m, params)
        if is_preopen(m)
            process_preopen!(s, b, m, params)
        elseif is_opening(m)
            process_open!(s, b, m, params)
        elseif is_open(m)
            process!(s, b, m, params)
        elseif is_closing(m)
            process_close!(s, b, m, params)
        elseif is_closed(m)
            process_postclose!(s, b, m, params)
        end
        update_statistics!(s, b, m, params)
    end
    finalize!(s, b, m, params)
    return params.statistics
end

end # module
