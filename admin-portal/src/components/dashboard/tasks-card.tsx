import { cn } from "@/lib/utils";
import { colorMap } from "./color-map";

export const taskData = [
  { label: "VKYC", value: 12, color: "sky" },
  { label: "BKYC", value: 8, color: "emerald" },
  { label: "Activation", value: 5, color: "amber" },
];

function TaskCard({ label, value, color }: typeof taskData[0]) {
  const c = colorMap[color];
  return (
    <div className="bg-white rounded-xl border border-blue-100/60 shadow-sm p-3 flex items-center gap-3 hover:shadow-sm transition-all cursor-pointer">
      <div className={cn("w-8 h-8 rounded-lg flex items-center justify-center", c.iconBg)}>
        <span className={cn("text-sm font-bold", c.text)}>{value}</span>
      </div>
      <div>
        <p className="text-sm font-medium text-gray-700">{label}</p>
        <p className="text-xs text-gray-400">Pending reviews</p>
      </div>
    </div>
  );
}

export default function TasksCardContainer() {
  return (
    <div className="bg-white rounded-xl border border-blue-100/60 shadow-sm p-4">
      <h2 className="text-sm font-semibold text-gray-900 mb-3">Pending Tasks</h2>
      <div className="space-y-2">
        {taskData.map((item) => (
          <TaskCard key={item.label} {...item} />
        ))}
      </div>
    </div>
  );
}
