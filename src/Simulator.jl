module Simulator

using Brokerages: AbstractBrokerage, tick!
using Markets:
    AbstractMarket,
    is_preopen,
    is_opening,
    is_open,
    is_closing,
    is_closed
using TradingBase:
    AbstractMarketDataProvider,
    LiveMarketDataProvider,
    SimulatedMarketDataProvider
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
    run!,
    sleep_til_preopen,
    sleep_til_opening,
    sleep_til_open,
    sleep_til_closing,
    sleep_til_close

include("strategy.jl")
include("statistics.jl")

function sleep_til_preopen(b, m::LiveMarketDataProvider)
    t = get_clock(m)
    sleep_til = Date(today() + Day(1)) + Time(9)
    @info "Sleeping until $sleep_til"
    sleep(sleep_til - Time(t))
end
function sleep_til_opening(b, m::LiveMarketDataProvider)
    t = get_clock(m)
    sleep_til = Time(9, 30)
    @info "Sleeping until $sleep_til"
    sleep(sleep_til - Time(t))
end
function sleep_til_open(b, m::LiveMarketDataProvider)
    t = get_clock(m)
    sleep_til = Time(9, 35)
    @info "Sleeping until $sleep_til"
    sleep(sleep_til - Time(t))
end
function sleep_til_closing(b, m::LiveMarketDataProvider)
    t = get_clock(m)
    sleep_til = Time(15, 55)
    @info "Sleeping until $sleep_til"
    sleep(sleep_til - Time(t))
end
function sleep_til_close(b, m::LiveMarketDataProvider)
    t = get_clock(m)
    sleep_til = Time(16)
    @info "Sleeping until $sleep_til"
    sleep(sleep_til - Time(t))
end
sleep_til_preopen(b, m::SimulatedMarketDataProvider) = tick!(b)
sleep_til_opening(b, m::SimulatedMarketDataProvider) = tick!(b)
sleep_til_open(b, m::SimulatedMarketDataProvider) = tick!(b)
sleep_til_closing(b, m::SimulatedMarketDataProvider) = tick!(b)
sleep_til_close(b, m::SimulatedMarketDataProvider) = tick!(b)
function run!(s::AbstractStrategy, b::AbstractBrokerage, m::AbstractMarketDataProvider)
    params = initialize!(s, b, m)
    while should_run(s, b, m, params)
        if is_preopen(m)
            process_preopen!(s, b, m, params)
            sleep_til_opening(b, m)
        elseif is_opening(m)
            process_open!(s, b, m, params)
            sleep_til_open(b, m)
        elseif is_open(m)
            process!(s, b, m, params)
            sleep_til_closing(b, m)
        elseif is_closing(m)
            process_close!(s, b, m, params)
            sleep_til_close(b, m)
        elseif is_closed(m)
            process_postclose!(s, b, m, params)
            sleep_til_preopen(b, m)
        end
        update_statistics!(s, b, m, params)
    end
    finalize!(s, b, m, params)
    return params.statistics
end

end # module
