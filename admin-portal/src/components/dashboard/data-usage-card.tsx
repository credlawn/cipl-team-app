import { cn } from "@/lib/utils";
import { colorMap } from "./color-map";

export const dataUsageData = [
  { label: "New", value: "120", sub: "4 employees with 0", color: "emerald" },
  { label: "Worked", value: "87", sub: "72.5% of allocated", color: "blue" },
  { label: "Used", value: "65", sub: "54.2% conversion", color: "amber" },
  { label: "Prod%", value: "74.7%", sub: "+2.3% vs yesterday", color: "violet" },
];

function DataUsageCard({ label, value, sub, color }: typeof dataUsageData[0]) {
  const c = colorMap[color];
  return (
    <div className="bg-white rounded-lg border border-blue-100/60 shadow-sm p-3">
      <div className="flex items-center justify-between mb-0.5">
        <span className="text-[11px] font-medium text-gray-400 uppercase tracking-wider">{label}</span>
        <div className={cn("w-1.5 h-1.5 rounded-full", c.bg.replace("50", "500"))} />
      </div>
      <p className="text-lg font-bold text-gray-900">{value}</p>
      <p className="text-[11px] text-gray-400 mt-0.5">{sub}</p>
    </div>
  );
}

export default function DataUsageCardContainer() {
  return (
    <div className="bg-white rounded-xl border border-blue-100/60 shadow-sm p-3">
      <h2 className="text-xs font-semibold text-gray-900 mb-2">Data Usage</h2>
      <div className="grid grid-cols-4 gap-1.5">
        {dataUsageData.map((item) => (
          <DataUsageCard key={item.label} {...item} />
        ))}
      </div>
    </div>
  );
}
