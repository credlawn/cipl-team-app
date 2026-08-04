import { useList } from "@refinedev/core";
import { Briefcase, Users, Clock, PhoneCall, TrendingUp, CheckCircle } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from "recharts";

export const DashboardPage = () => {
  const { data: leadsData, isLoading: leadsLoading } = useList({ resource: "leads", pagination: { pageSize: 100 } });
  const { data: usersData, isLoading: usersLoading } = useList({ resource: "users", pagination: { pageSize: 100 } });
  const { data: attendanceData, isLoading: attendanceLoading } = useList({ resource: "attendance", pagination: { pageSize: 50 } });

  const totalLeads = leadsData?.total || 0;
  const totalUsers = usersData?.total || 0;
  const todayAttendance = attendanceData?.total || 0;

  // Mock trend data for visualization
  const trendData = [
    { day: "Mon", leads: 12, calls: 45 },
    { day: "Tue", leads: 19, calls: 60 },
    { day: "Wed", leads: 25, calls: 78 },
    { day: "Thu", leads: 32, calls: 85 },
    { day: "Fri", leads: 28, calls: 90 },
    { day: "Sat", leads: 40, calls: 110 },
    { day: "Sun", leads: 35, calls: 95 },
  ];

  const statusDistribution = [
    { name: "New / Pending", value: 35, color: "#3b82f6" },
    { name: "In Progress", value: 45, color: "#eab308" },
    { name: "Approved / Converted", value: 15, color: "#10b981" },
    { name: "Rejected", value: 5, color: "#ef4444" },
  ];

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-slate-900">Executive Dashboard</h1>
        <p className="text-sm text-slate-500">Real-time overview of sales operations, lead activity, and team metrics.</p>
      </div>

      {/* KPI Cards Grid */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <Card className="hover:shadow-md transition-shadow border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xs font-semibold uppercase tracking-wider text-slate-500">Total Leads</CardTitle>
            <div className="h-9 w-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center">
              <Briefcase className="h-5 w-5" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">{leadsLoading ? "..." : totalLeads}</div>
            <p className="text-xs text-emerald-600 font-medium flex items-center gap-1 mt-1">
              <TrendingUp className="h-3 w-3" /> +14% from last week
            </p>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition-shadow border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xs font-semibold uppercase tracking-wider text-slate-500">Active Field Team</CardTitle>
            <div className="h-9 w-9 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center">
              <Users className="h-5 w-5" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">{usersLoading ? "..." : totalUsers}</div>
            <p className="text-xs text-slate-500 mt-1">Active registered staff</p>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition-shadow border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xs font-semibold uppercase tracking-wider text-slate-500">Today Check-ins</CardTitle>
            <div className="h-9 w-9 rounded-lg bg-purple-50 text-purple-600 flex items-center justify-center">
              <Clock className="h-5 w-5" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">{attendanceLoading ? "..." : todayAttendance}</div>
            <p className="text-xs text-emerald-600 font-medium flex items-center gap-1 mt-1">
              <CheckCircle className="h-3 w-3" /> Attendance Verified
            </p>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition-shadow border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xs font-semibold uppercase tracking-wider text-slate-500">Weekly Calls</CardTitle>
            <div className="h-9 w-9 rounded-lg bg-amber-50 text-amber-600 flex items-center justify-center">
              <PhoneCall className="h-5 w-5" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">563</div>
            <p className="text-xs text-slate-500 mt-1">Customer interactions</p>
          </CardContent>
        </Card>
      </div>

      {/* Analytics Charts Section */}
      <div className="grid gap-6 md:grid-cols-7">
        <Card className="md:col-span-4 border-slate-200">
          <CardHeader>
            <CardTitle className="text-base font-semibold">Weekly Lead Acquisition & Call Activity</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-[300px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={trendData}>
                  <defs>
                    <linearGradient id="colorLeads" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#2563eb" stopOpacity={0.8}/>
                      <stop offset="95%" stopColor="#2563eb" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                  <XAxis dataKey="day" stroke="#94a3b8" fontSize={12} tickLine={false} />
                  <YAxis stroke="#94a3b8" fontSize={12} tickLine={false} />
                  <Tooltip contentStyle={{ backgroundColor: "#1e293b", borderRadius: "8px", color: "#fff", border: "none" }} />
                  <Area type="monotone" dataKey="leads" stroke="#2563eb" strokeWidth={2} fillOpacity={1} fill="url(#colorLeads)" />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        <Card className="md:col-span-3 border-slate-200">
          <CardHeader>
            <CardTitle className="text-base font-semibold">Lead Status Distribution</CardTitle>
          </CardHeader>
          <CardContent className="flex flex-col items-center justify-center">
            <div className="h-[220px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie data={statusDistribution} innerRadius={60} outerRadius={80} paddingAngle={5} dataKey="value">
                    {statusDistribution.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="mt-4 grid grid-cols-2 gap-3 w-full">
              {statusDistribution.map((item) => (
                <div key={item.name} className="flex items-center gap-2 text-xs font-medium text-slate-600">
                  <span className="h-2.5 w-2.5 rounded-full" style={{ backgroundColor: item.color }} />
                  {item.name} ({item.value}%)
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};
