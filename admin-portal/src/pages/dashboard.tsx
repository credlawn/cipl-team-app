import OverviewCard from "@/components/dashboard/overview-card";
import DataUsageCardContainer from "@/components/dashboard/data-usage-card";
import TasksCardContainer from "@/components/dashboard/tasks-card";
import LeadStatusChart from "@/components/dashboard/lead-status-chart";
import AttendanceChart from "@/components/dashboard/attendance-chart";
import EmployeeTable from "@/components/dashboard/employee-table";
import CallActivityChart from "@/components/dashboard/call-activity-chart";

export default function DashboardPage() {
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <OverviewCard />
        <DataUsageCardContainer />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-4">
        <div className="lg:col-span-1">
          <TasksCardContainer />
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <LeadStatusChart />
        <AttendanceChart />
      </div>

      <EmployeeTable />

      <CallActivityChart />
    </div>
  );
}
