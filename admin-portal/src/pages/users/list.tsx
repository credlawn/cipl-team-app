import { useState } from "react";
import { useList } from "@refinedev/core";
import { useNavigate } from "react-router-dom";
import {
  Search,
  Shield,
  Mail,
  Phone,
  RefreshCw,
  Briefcase,
  Eye,
  Filter,
  UserCheck,
  UserX,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { Skeleton } from "@/components/ui/skeleton";
import { pb } from "@/lib/pocketbase";

type StatusFilterOption = "active" | "inactive" | "all";

export const UserListPage = () => {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState<StatusFilterOption>("active");

  const filters: any[] = [];
  if (searchQuery) {
    filters.push({ field: "employee_name", operator: "contains", value: searchQuery });
  }

  // Filter logic: Default "active" (disabled = false), "inactive" (disabled = true), or "all"
  if (statusFilter === "active") {
    filters.push({ field: "disabled", operator: "eq", value: false });
  } else if (statusFilter === "inactive") {
    filters.push({ field: "disabled", operator: "eq", value: true });
  }

  const { data, isLoading, refetch } = useList({
    resource: "users",
    pagination: { pageSize: 100 },
    filters,
    sorters: [{ field: "created", order: "desc" }],
  });

  const users = data?.data || [];

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Team & Personnel Directory</h1>
          <p className="text-sm text-slate-500">Manage field sales personnel, active user accounts, and system roles.</p>
        </div>
        <Button onClick={() => refetch()} variant="outline" className="gap-2">
          <RefreshCw className="h-4 w-4" /> Refresh Users
        </Button>
      </div>

      {/* Filter & Search Bar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-3 bg-white p-4 rounded-xl border border-slate-200 shadow-xs">
        <div className="relative flex-1 w-full">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
          <Input
            placeholder="Search team member by employee name or code..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-9"
          />
        </div>

        {/* Status Filter Selector (Default: Active Personnel) */}
        <div className="flex items-center gap-2 w-full sm:w-auto">
          <Filter className="h-4 w-4 text-slate-500 hidden sm:block" />
          <div className="flex items-center gap-1 bg-slate-100 p-1 rounded-lg w-full sm:w-auto">
            <Button
              size="sm"
              variant={statusFilter === "active" ? "default" : "ghost"}
              onClick={() => setStatusFilter("active")}
              className="text-xs h-8 gap-1"
            >
              <UserCheck className="h-3.5 w-3.5" /> Active Staff
            </Button>
            <Button
              size="sm"
              variant={statusFilter === "inactive" ? "default" : "ghost"}
              onClick={() => setStatusFilter("inactive")}
              className="text-xs h-8 gap-1"
            >
              <UserX className="h-3.5 w-3.5" /> Inactive / Disabled
            </Button>
            <Button
              size="sm"
              variant={statusFilter === "all" ? "default" : "ghost"}
              onClick={() => setStatusFilter("all")}
              className="text-xs h-8"
            >
              All Personnel
            </Button>
          </div>
        </div>
      </div>

      {/* Data Table */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-xs overflow-hidden">
        {isLoading ? (
          <div className="p-6 space-y-4">
            <Skeleton className="h-8 w-full" />
            <Skeleton className="h-12 w-full" />
            <Skeleton className="h-12 w-full" />
          </div>
        ) : users.length === 0 ? (
          <div className="p-12 text-center text-slate-500">
            <p className="text-base font-semibold text-slate-700">No personnel records found for this status filter</p>
            <p className="text-xs text-slate-400 mt-1">Try switching to "Inactive / Disabled" or "All Personnel".</p>
          </div>
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Personnel Name & Code</TableHead>
                <TableHead>Contact Email / Mobile</TableHead>
                <TableHead>Role & Department</TableHead>
                <TableHead>Work Mode</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {users.map((user: any) => {
                const name = user.employee_name || user.email || "Unnamed User";
                const avatarUrl = user.avatar ? pb.files.getUrl(user, user.avatar) : null;

                return (
                  <TableRow
                    key={user.id}
                    onClick={() => navigate(`/users/${user.id}`)}
                    className="hover:bg-blue-50/40 cursor-pointer transition-colors"
                  >
                    <TableCell className="font-semibold text-slate-900">
                      <div className="flex items-center gap-3">
                        {avatarUrl ? (
                          <img src={avatarUrl} alt={name} className="h-9 w-9 rounded-full object-cover border border-slate-200" />
                        ) : (
                          <div className="flex h-9 w-9 items-center justify-center rounded-full bg-blue-100 text-blue-700 font-bold text-xs">
                            {name.charAt(0).toUpperCase()}
                          </div>
                        )}
                        <div>
                          <p className="leading-tight text-slate-900 font-bold hover:text-blue-600 transition-colors">{name}</p>
                          <p className="text-xs text-slate-500 font-mono font-normal">
                            {user.employee_code || user.id} • {user.designation || "Executive"}
                          </p>
                        </div>
                      </div>
                    </TableCell>

                    <TableCell className="text-slate-600 text-xs font-mono">
                      <div className="space-y-0.5">
                        <span className="flex items-center gap-1">
                          <Mail className="h-3.5 w-3.5 text-slate-400" />
                          {user.email || "—"}
                        </span>
                        {user.mobile_no && (
                          <span className="flex items-center gap-1 text-slate-500">
                            <Phone className="h-3.5 w-3.5 text-slate-400" />
                            {user.mobile_no}
                          </span>
                        )}
                      </div>
                    </TableCell>

                    <TableCell>
                      <div className="flex items-center gap-2">
                        <Badge variant="secondary" className="capitalize">
                          <Shield className="h-3 w-3 mr-1 text-slate-500" />
                          {user.role || "Employee"}
                        </Badge>
                        {user.department && (
                          <span className="text-xs text-slate-500">({user.department})</span>
                        )}
                      </div>
                    </TableCell>

                    <TableCell>
                      <div className="flex items-center gap-1">
                        {user.wfh ? (
                          <Badge variant="secondary" className="bg-purple-50 text-purple-700 border-purple-200 text-[10px]">
                            WFH
                          </Badge>
                        ) : (
                          <Badge variant="outline" className="text-[10px]">
                            In-Office
                          </Badge>
                        )}
                        {user.on_duty && (
                          <Badge variant="secondary" className="bg-amber-50 text-amber-700 border-amber-200 text-[10px]">
                            <Briefcase className="h-3 w-3 mr-0.5" /> On Duty
                          </Badge>
                        )}
                      </div>
                    </TableCell>

                    <TableCell>
                      {user.disabled ? (
                        <Badge variant="destructive">Inactive / Disabled</Badge>
                      ) : (
                        <Badge variant="success">Active</Badge>
                      )}
                    </TableCell>

                    <TableCell className="text-right">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={(e) => {
                          e.stopPropagation();
                          navigate(`/users/${user.id}`);
                        }}
                        className="gap-1 text-blue-600 hover:text-blue-800 hover:bg-blue-50 font-bold"
                      >
                        <Eye className="h-4 w-4" /> Open Form
                      </Button>
                    </TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        )}
      </div>
    </div>
  );
};
