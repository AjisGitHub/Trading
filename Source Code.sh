//@version=6
indicator("Ultimate RSI + RMI Sniper PRO", overlay=true, max_labels_count=500)

// ===== INPUTS =====
rsiLen = input.int(14, "RSI Length")
rmiLen = input.int(14, "RMI Length")
emaLen = input.int(20, "EMA Length")

strongBuyLevel = input.int(60, "Strong Buy RSI")
buyLevel = input.int(50, "Buy RSI")
strongSellLevel = input.int(30, "Strong Sell RSI")

// ===== RMI =====
chg = ta.change(close)

up = ta.rma(math.max(chg,0), rmiLen)
down = ta.rma(math.max(-chg,0), rmiLen)

rs = down == 0 ? 100 : up/down
rsi_calc = 100 - (100/(1+rs))

mf = ta.mfi(hlc3,rmiLen)

rmi = (rsi_calc + mf)/2

// ===== TREND =====
emaTrend = ta.ema(close,emaLen)

bullTrend = close > emaTrend and rmi > 50
bearTrend = close < emaTrend and rmi < 50

plot(emaTrend,color=color.yellow,linewidth=2)

// ===== RSI =====
rsi = ta.rsi(close,rsiLen)

// ===== SIGNAL STATE =====
// 1 = buy mode
// -1 = sell mode
// 0 = neutral

var int state = 0

newStrongBuy = ta.crossover(rsi,strongBuyLevel) and bullTrend
newBuy = ta.crossover(rsi,buyLevel) and bullTrend

newStrongSell = ta.crossunder(rsi,strongSellLevel) and bearTrend
newSell = ta.crossunder(rsi,buyLevel) and bearTrend

strongBuy = false
buy = false
sell = false
strongSell = false

if (newStrongBuy or newBuy) and state != 1
    state := 1
    strongBuy := newStrongBuy
    buy := not newStrongBuy

if (newStrongSell or newSell) and state != -1
    state := -1
    strongSell := newStrongSell
    sell := not newStrongSell

// ===== LABELS =====

if strongBuy
    label.new(bar_index,low,"🚀 STRONG BUY",
     style=label.style_label_up,
     color=color.lime)

if buy
    label.new(bar_index,low,"BUY",
     style=label.style_label_up,
     color=color.green)

if strongSell
    label.new(bar_index,high,"💀 STRONG SELL",
     style=label.style_label_down,
     color=color.red)

if sell
    label.new(bar_index,high,"SELL",
     style=label.style_label_down,
     color=color.orange)

// ===== MTF RSI =====

rsi1h = request.security(syminfo.tickerid,"60",ta.rsi(close,14))
rsi4h = request.security(syminfo.tickerid,"240",ta.rsi(close,14))
rsi1d = request.security(syminfo.tickerid,"D",ta.rsi(close,14))
rsi1w = request.security(syminfo.tickerid,"W",ta.rsi(close,14))
rsi1m = request.security(syminfo.tickerid,"M",ta.rsi(close,14))
rsi1y = request.security(syminfo.tickerid,"12M",ta.rsi(close,14))

// ===== TABLE =====

var table t = table.new(position.top_right,2,7,border_width=1)

if barstate.islast
    table.cell(t,0,0,"TF")
    table.cell(t,1,0,"RSI")

    table.cell(t,0,1,"1H")
    table.cell(t,1,1,str.tostring(rsi1h,"#.0"))

    table.cell(t,0,2,"4H")
    table.cell(t,1,2,str.tostring(rsi4h,"#.0"))

    table.cell(t,0,3,"1D")
    table.cell(t,1,3,str.tostring(rsi1d,"#.0"))

    table.cell(t,0,4,"1W")
    table.cell(t,1,4,str.tostring(rsi1w,"#.0"))

    table.cell(t,0,5,"1M")
    table.cell(t,1,5,str.tostring(rsi1m,"#.0"))

    table.cell(t,0,6,"1Y")
    table.cell(t,1,6,str.tostring(rsi1y,"#.0"))

// ===== ALERTS =====
alertcondition(strongBuy,title="Strong Buy",message="Strong Buy")
alertcondition(buy,title="Buy",message="Buy")
alertcondition(sell,title="Sell",message="Sell")
alertcondition(strongSell,title="Strong Sell",message="Strong Sell")
