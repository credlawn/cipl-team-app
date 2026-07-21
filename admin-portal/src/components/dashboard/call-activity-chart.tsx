import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts";

export const hourlyCallData = [
  { hour: "10AM", calls: 12, duration: 45 },
  { hour: "11AM", calls: 18, duration: 62 },
  { hour: "12PM", calls: 22, duration: 78 },
  { hour: "1PM", calls: 10, duration: 35 },
  { hour: "2PM", calls: 20, duration: 71 },
  { hour: "3PM", calls: 25, duration: 88 },
  { hour: "4PM", calls: 19, duration: 66 },
  { hour: "5PM", calls: 14, duration: 52 },
  { hour: "6PM", calls: 8, duration: 28 },
];

export default function CallActivityChart() {
  return (
    <div className="bg-white rounded-xl border border-blue-100/60 shadow-sm p-4">
      <div className="flex items-center justify-between mb-3">
        <h2 className="text-sm font-semibold text-gray-900">Hourly Call Activity</h2>
        <div className="flex items-center gap-4 text-xs text-gray-400">
          <span className="flex items-center gap-1">
            <span className="w-2.5 h-2.5 rounded-full bg-blue-500" /> Calls
          </span>
          <span className="flex items-center gap-1">
            <span className="w-2.5 h-2.5 rounded-full bg-violet-400" /> Duration (min)
          </span>
        </div>
      </div>
      <div className="h-52">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={hourlyCallData} margin={{ top: 5, right: 10, left: -10, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
            <XAxis dataKey="hour" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: "#94a3b8" }} />
            <YAxis yAxisId="left" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: "#94a3b8" }} />
            <YAxis yAxisId="right" orientation="right" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: "#94a3b8" }} />
            <Tooltip
              contentStyle={{ borderRadius: 8, border: "1px solid #e2e8f0", fontSize: 12, boxShadow: "0 2px 8px rgba(0,0,0,0.06)" }}
            />
            <Bar yAxisId="left" dataKey="calls" fill="#3B82F6" radius={[4, 4, 0, 0]} barSize={20} name="Calls" />
            <Bar yAxisId="right" dataKey="duration" fill="#A78BFA" radius={[4, 4, 0, 0]} barSize={20} name="Duration (min)" />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
