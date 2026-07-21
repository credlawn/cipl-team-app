import { cn } from "@/lib/utils";
import { TrendingUp, TrendingDown } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { useOverview } from "@/hooks/use-overview";

export default function OverviewCard() {
  const navigate = useNavigate();
  const { data, loading } = useOverview();

  const today = data?.today;
  const yesterday = data?.yesterday;
  const chg = data?.change;

  const items = loading ? null : [
    {
      label: "IPA", value: today!.ipa, yesterdayValue: yesterday!.ipa, change: chg!.ipa, valueColor: "text-emerald-600", isPct: false,
      thirdLine: data!.zero_ipa > 0
        ? { text: `${data!.zero_ipa} emp with 0`, color: "text-red-500" }
        : data!.below_avg_ipa > 0
        ? { text: `${data!.below_avg_ipa} emp below avg`, color: "text-amber-500" }
        : null,
    },
    {
      label: "IPD", value: today!.ipd, yesterdayValue: yesterday!.ipd, change: chg!.ipd, valueColor: "text-red-600", isPct: false,
      thirdLine: data!.above_avg_ipd > 0
        ? { text: `${data!.above_avg_ipd} emp above avg`, color: "text-red-500" }
        : null,
    },
    {
      label: "Total", value: today!.ipa + today!.ipd, yesterdayValue: yesterday!.ipa + yesterday!.ipd, change: (today!.ipa + today!.ipd) - (yesterday!.ipa + yesterday!.ipd), valueColor: "text-blue-600", isPct: false,
      thirdLine: null,
    },
    {
      label: "IPA%", value: Math.round(data!.today_pct), yesterdayValue: Math.round(data!.yes_pct), change: data!.change_pct, valueColor: "text-violet-600", isPct: true,
      thirdLine: null,
    },
  ];

  return (
    <div
      className="bg-white rounded-xl border border-blue-100/60 shadow-sm p-3 cursor-pointer transition-colors hover:bg-gray-50/50"
      onClick={() => navigate("/dashboard/overview-detail")}
    >
      <div className="flex items-center justify-between mb-2">
        <h2 className="text-xs font-semibold text-gray-900">Overview</h2>
        <span className="text-[11px] text-gray-400">vs yesterday</span>
      </div>
      <div className="grid grid-cols-4 gap-1.5">
        {loading ? (
          Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="bg-white rounded-lg border border-blue-100/60 shadow-sm p-2.5">
                <div className="h-2.5 w-8 bg-gray-100 rounded animate-pulse mb-1" />
                <div className="h-4 w-12 bg-gray-100 rounded animate-pulse" />
            </div>
          ))
        ) : (
          items!.map((item) => {
            const isPos = item.change >= 0;
            const isGood = item.label === "IPD" ? !isPos : isPos;
            return (
              <div key={item.label} className="bg-white rounded-lg border border-blue-100/60 shadow-sm p-3">
                <div className="flex items-center justify-between mb-1">
                  <span className="text-[11px] font-medium text-gray-400 uppercase tracking-wider">{item.label}</span>
                  <span className={cn(
                    "inline-flex items-center gap-0.5 text-[11px] font-medium",
                    isGood ? "text-emerald-600" : "text-red-600"
                  )}>
                    {isPos ? <TrendingUp className="w-2.5 h-2.5" /> : <TrendingDown className="w-2.5 h-2.5" />}
                    {Math.round(Math.abs(item.change))}{item.isPct ? "%" : ""}
                  </span>
                </div>
                <p className="text-lg font-bold inline-flex items-baseline gap-2">
                  <span className={item.valueColor}>{item.value}{item.isPct && <span className="text-xs font-normal text-gray-400">%</span>}</span>
                  <span className="text-[11px] font-medium text-gray-400">{item.yesterdayValue}{item.isPct ? "%" : ""}</span>
                </p>
                {item.thirdLine && (
                  <p className={`text-[11px] mt-0.5 ${item.thirdLine.color}`}>{item.thirdLine.text}</p>
                )}
              </div>
            );
          })
        )}
      </div>
    </div>
  );
}
