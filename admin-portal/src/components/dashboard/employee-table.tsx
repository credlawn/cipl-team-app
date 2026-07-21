import { cn } from "@/lib/utils";

export const employeeData = [
  { rank: 1, name: "Rajesh Kumar", new: 15, worked: 12, productivity: 80.0, ipa: 75.0, role: "Executive" },
  { rank: 2, name: "Priya Sharma", new: 12, worked: 10, productivity: 83.3, ipa: 70.0, role: "Executive" },
  { rank: 3, name: "Amit Singh", new: 11, worked: 9, productivity: 81.8, ipa: 66.7, role: "Senior Executive" },
  { rank: 4, name: "Sneha Patel", new: 10, worked: 8, productivity: 80.0, ipa: 62.5, role: "Executive" },
  { rank: 5, name: "Vikram Reddy", new: 8, worked: 7, productivity: 87.5, ipa: 71.4, role: "Executive" },
];

export default function EmployeeTable() {
  return (
    <div className="bg-white rounded-xl border border-blue-100/60 shadow-sm p-4">
      <div className="flex items-center justify-between mb-3">
        <h2 className="text-sm font-semibold text-gray-900">Employee Performance</h2>
        <button className="text-xs text-blue-600 hover:text-blue-700 font-medium cursor-pointer">View All</button>
      </div>
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-blue-100/60">
              <th className="text-left py-3 px-2 text-xs font-medium text-gray-400 uppercase tracking-wider">#</th>
              <th className="text-left py-3 px-2 text-xs font-medium text-gray-400 uppercase tracking-wider">Name</th>
              <th className="text-right py-3 px-2 text-xs font-medium text-gray-400 uppercase tracking-wider">New</th>
              <th className="text-right py-3 px-2 text-xs font-medium text-gray-400 uppercase tracking-wider">Worked</th>
              <th className="text-right py-3 px-2 text-xs font-medium text-gray-400 uppercase tracking-wider">Prod%</th>
              <th className="text-right py-3 px-2 text-xs font-medium text-gray-400 uppercase tracking-wider">IPA%</th>
              <th className="text-right py-3 px-2 text-xs font-medium text-gray-400 uppercase tracking-wider">Role</th>
            </tr>
          </thead>
          <tbody>
            {employeeData.map((emp) => (
              <tr key={emp.rank} className="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                <td className="py-3 px-2 text-gray-400 text-xs">{emp.rank}</td>
                <td className="py-3 px-2 font-medium text-gray-900">{emp.name}</td>
                <td className="py-3 px-2 text-right text-gray-700">{emp.new}</td>
                <td className="py-3 px-2 text-right text-gray-700">{emp.worked}</td>
                <td className="py-3 px-2 text-right">
                  <span className={cn(
                    "text-xs font-medium px-1.5 py-0.5 rounded-full",
                    emp.productivity >= 80 ? "bg-emerald-50 text-emerald-700" :
                    emp.productivity >= 60 ? "bg-amber-50 text-amber-700" :
                    "bg-red-50 text-red-700"
                  )}>
                    {emp.productivity}%
                  </span>
                </td>
                <td className="py-3 px-2 text-right">
                  <span className={cn(
                    "text-xs font-medium px-1.5 py-0.5 rounded-full",
                    emp.ipa >= 70 ? "bg-emerald-50 text-emerald-700" :
                    emp.ipa >= 50 ? "bg-amber-50 text-amber-700" :
                    "bg-red-50 text-red-700"
                  )}>
                    {emp.ipa}%
                  </span>
                </td>
                <td className="py-3 px-2 text-right text-xs text-gray-400">{emp.role}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
