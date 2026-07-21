import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer } from "recharts";

export const attendanceData = [
  { name: "Present", value: 32, color: "#10B981" },
  { name: "Absent", value: 8, color: "#EF4444" },
  { name: "Late", value: 5, color: "#F59E0B" },
];

export default function AttendanceChart() {
  return (
    <div className="bg-white rounded-xl border border-blue-100/60 shadow-sm p-4">
      <div className="flex items-center justify-between mb-3">
        <h2 className="text-sm font-semibold text-gray-900">Attendance Today</h2>
        <span className="text-xs text-gray-400">45 active employees</span>
      </div>
      <div className="flex items-center justify-center h-44">
        <div className="relative">
          <ResponsiveContainer width={200} height={200}>
            <PieChart>
              <Pie
                data={attendanceData}
                cx="50%" cy="50%"
                innerRadius={60} outerRadius={80}
                paddingAngle={3}
                dataKey="value"
                stroke="none"
              >
                {attendanceData.map((entry) => (
                  <Cell key={entry.name} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip
                contentStyle={{ borderRadius: 8, border: "1px solid #e2e8f0", fontSize: 12 }}
              />
            </PieChart>
          </ResponsiveContainer>
          <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
            <div className="text-center">
              <p className="text-2xl font-bold text-gray-900">{attendanceData.reduce((a, b) => a + b.value, 0)}</p>
              <p className="text-xs text-gray-400">Total</p>
            </div>
          </div>
        </div>
        <div className="space-y-3 ml-4">
          {attendanceData.map((item) => (
            <div key={item.name} className="flex items-center gap-2">
              <div className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: item.color }} />
              <span className="text-sm text-gray-600 w-14">{item.name}</span>
              <span className="text-sm font-semibold text-gray-900">{item.value}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
