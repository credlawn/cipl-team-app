import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell } from "recharts";

export const leadStatusData = [
  { status: "New", count: 120, color: "#3B82F6" },
  { status: "Called", count: 85, color: "#8B5CF6" },
  { status: "CNR", count: 45, color: "#F59E0B" },
  { status: "Denied", count: 23, color: "#EF4444" },
  { status: "IP Approved", count: 35, color: "#10B981" },
  { status: "IP Decline", count: 12, color: "#F97316" },
  { status: "No Docs", count: 18, color: "#6366F1" },
];

export default function LeadStatusChart() {
  return (
    <div className="bg-white rounded-xl border border-blue-100/60 shadow-sm p-4">
      <div className="flex items-center justify-between mb-3">
        <h2 className="text-sm font-semibold text-gray-900">Lead Status Breakdown</h2>
        <span className="text-xs text-gray-400">Today</span>
      </div>
      <div className="h-52">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={leadStatusData} layout="vertical" margin={{ left: -10, right: 20, top: 0, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" horizontal={false} />
            <XAxis type="number" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: "#94a3b8" }} />
            <YAxis type="category" dataKey="status" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: "#64748b" }} width={90} />
            <Tooltip
              contentStyle={{ borderRadius: 8, border: "1px solid #e2e8f0", fontSize: 12, boxShadow: "0 2px 8px rgba(0,0,0,0.06)" }}
              cursor={{ fill: "#f8fafc" }}
            />
            <Bar dataKey="count" radius={[0, 4, 4, 0]} barSize={16}>
              {leadStatusData.map((entry) => (
                <Cell key={entry.status} fill={entry.color} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
