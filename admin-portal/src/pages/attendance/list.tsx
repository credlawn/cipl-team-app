import { useState, useMemo } from "react";
import { useList } from "@refinedev/core";
import { Clock, MapPin, Camera, RefreshCw, Search, CheckCircle2, XCircle, UserCheck, Calendar, Briefcase, ExternalLink } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { Skeleton } from "@/components/ui/skeleton";
import { pb } from "@/lib/pocketbase";

type DateFilterOption = "today" | "this_month" | "all";

export const AttendanceListPage = () => {
  const [selectedPhoto, setSelectedPhoto] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [dateFilter, setDateFilter] = useState<DateFilterOption>("today");

  // 1. Fetch active employees (disabled != true && no_atn != true)
  const { data: usersData, isLoading: usersLoading, refetch: refetchUsers } = useList({
    resource: "users",
    pagination: { pageSize: 300 },
  });

  // Filter active employees using exact schema field names (disabled & no_atn)
  const activeEmployees = useMemo(() => {
    const rawUsers = usersData?.data || [];
    return rawUsers.filter((u: any) => u.disabled !== true && u.no_atn !== true);
  }, [usersData]);

  // 2. Compute date filter for attendance collection using exact field `attendance_date`
  const attendanceFilters = useMemo(() => {
    const filters: any[] = [];
    const now = new Date();
    const todayStr = now.toISOString().split("T")[0]; // YYYY-MM-DD

    if (dateFilter === "today") {
      filters.push({ field: "attendance_date", operator: "contains", value: todayStr });
    } else if (dateFilter === "this_month") {
      const yearMonth = todayStr.substring(0, 7); // YYYY-MM
      filters.push({ field: "attendance_date", operator: "contains", value: yearMonth });
    }
    return filters;
  }, [dateFilter]);

  // 3. Fetch attendance records in descending order
  const { data: attendanceData, isLoading: attendanceLoading, refetch: refetchAttendance } = useList({
    resource: "attendance",
    pagination: { pageSize: 500 },
    filters: attendanceFilters,
    sorters: [{ field: "created", order: "desc" }],
    meta: { expand: "user" },
  });

  const attendanceLogs = attendanceData?.data || [];

  // 4. Merge Employees with Attendance Logs using exact JSON schema fields
  const mergedAttendanceList = useMemo(() => {
    // Map attendance logs by user ID or employee code
    const attendanceMap = new Map<string, any[]>();

    attendanceLogs.forEach((log: any) => {
      const key = log.user || log.employee_code || log.expand?.user?.id;
      if (key) {
        if (!attendanceMap.has(key)) {
          attendanceMap.set(key, []);
        }
        attendanceMap.get(key)!.push(log);
      }
    });

    const list: any[] = [];

    activeEmployees.forEach((emp: any) => {
      const empLogs = attendanceMap.get(emp.id) || (emp.employee_code ? attendanceMap.get(emp.employee_code) : []);

      if (empLogs && empLogs.length > 0) {
        // Person has attendance log(s)
        empLogs.forEach((log: any) => {
          // Construct file URL using official PocketBase SDK helper pb.files.getUrl
          let selfieUrl: string | null = null;
          if (log.check_in_selfie) {
            try {
              selfieUrl = pb.files.getUrl(log, log.check_in_selfie);
            } catch (e) {
              selfieUrl = `${pb.baseUrl}/api/files/${log.collectionId || "pbc_2471705857"}/${log.id}/${log.check_in_selfie}`;
            }
          }

          list.push({
            id: log.id,
            employee_code: emp.employee_code || log.employee_code || "N/A",
            name: emp.employee_name || log.employee_name || emp.email || "Employee",
            designation: emp.designation || emp.department || "Executive",
            department: emp.department || "Sales",
            isCheckedIn: true,
            checkInTime: log.check_in_time || log.created || log.attendance_date,
            checkOutTime: log.check_out_time,
            checkInSelfie: log.check_in_selfie,
            selfieUrl: selfieUrl,
            checkInLat: log.check_in_latitude,
            checkInLng: log.check_in_longitude,
            address: log.address,
            wfh: emp.wfh || false,
            onDuty: emp.on_duty || false,
            attendance_date: log.attendance_date || log.created,
            rawRecord: log,
          });
        });
      } else {
        // Person has NO attendance log -> Not Checked In / Absent
        list.push({
          id: `absent-${emp.id}`,
          employee_code: emp.employee_code || "N/A",
          name: emp.employee_name || emp.email || "Employee",
          designation: emp.designation || emp.department || "Executive",
          department: emp.department || "Sales",
          isCheckedIn: false,
          checkInTime: null,
          checkOutTime: null,
          checkInSelfie: null,
          selfieUrl: null,
          checkInLat: null,
          checkInLng: null,
          address: null,
          wfh: emp.wfh || false,
          onDuty: emp.on_duty || false,
          attendance_date: new Date().toISOString(),
          rawRecord: null,
        });
      }
    });

    // Filter by Search Query
    let filtered = list;
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      filtered = list.filter(
        (item) =>
          item.name.toLowerCase().includes(q) ||
          item.employee_code.toLowerCase().includes(q) ||
          item.designation.toLowerCase().includes(q) ||
          item.department.toLowerCase().includes(q)
      );
    }

    // Sort descending by attendance date / check-in time
    return filtered.sort((a, b) => {
      if (a.isCheckedIn && !b.isCheckedIn) return -1;
      if (!a.isCheckedIn && b.isCheckedIn) return 1;
      return new Date(b.attendance_date).getTime() - new Date(a.attendance_date).getTime();
    });
  }, [activeEmployees, attendanceLogs, searchQuery]);

  // Summary Metrics
  const totalStaffCount = activeEmployees.length;
  const presentCount = mergedAttendanceList.filter((item) => item.isCheckedIn).length;
  const absentCount = totalStaffCount - presentCount;
  const wfhCount = activeEmployees.filter((emp: any) => emp.wfh === true).length;

  const handleRefresh = () => {
    refetchUsers();
    refetchAttendance();
  };

  const isLoading = usersLoading || attendanceLoading;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Attendance & Personnel Monitoring</h1>
          <p className="text-sm text-slate-500">Live attendance verification, GPS tracking, and absence monitoring for active personnel.</p>
        </div>
        <Button onClick={handleRefresh} variant="outline" className="gap-2">
          <RefreshCw className="h-4 w-4" /> Refresh Data
        </Button>
      </div>

      {/* Summary KPI Bar */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <Card className="border-slate-200">
          <CardContent className="p-4 flex items-center justify-between">
            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase">Active Staff Roster</p>
              <p className="text-2xl font-bold text-slate-900">{totalStaffCount}</p>
              <p className="text-[11px] text-slate-400">disabled = false, no_atn = false</p>
            </div>
            <div className="h-10 w-10 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center font-bold">
              <UserCheck className="h-5 w-5" />
            </div>
          </CardContent>
        </Card>

        <Card className="border-slate-200">
          <CardContent className="p-4 flex items-center justify-between">
            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase">Checked In Today</p>
              <p className="text-2xl font-bold text-emerald-600">{presentCount}</p>
              <p className="text-[11px] text-emerald-600 font-medium">Present & Verified</p>
            </div>
            <div className="h-10 w-10 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center font-bold">
              <CheckCircle2 className="h-5 w-5" />
            </div>
          </CardContent>
        </Card>

        <Card className="border-slate-200">
          <CardContent className="p-4 flex items-center justify-between">
            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase">Not Checked In / Absent</p>
              <p className="text-2xl font-bold text-rose-600">{absentCount < 0 ? 0 : absentCount}</p>
              <p className="text-[11px] text-rose-500 font-medium">Pending Attendance</p>
            </div>
            <div className="h-10 w-10 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center font-bold">
              <XCircle className="h-5 w-5" />
            </div>
          </CardContent>
        </Card>

        <Card className="border-slate-200">
          <CardContent className="p-4 flex items-center justify-between">
            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase">Work From Home (WFH)</p>
              <p className="text-2xl font-bold text-purple-600">{wfhCount}</p>
              <p className="text-[11px] text-slate-400">Remote Duty Staff</p>
            </div>
            <div className="h-10 w-10 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center font-bold">
              <Clock className="h-5 w-5" />
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Filter & Search Bar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-3 bg-white p-4 rounded-xl border border-slate-200 shadow-xs">
        <div className="relative flex-1 w-full">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
          <Input
            placeholder="Search by Employee Name, Code (e.g. EMP-102), Designation..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-9"
          />
        </div>

        {/* Date Filter Buttons */}
        <div className="flex items-center gap-1.5 bg-slate-100 p-1 rounded-lg w-full sm:w-auto">
          <Button
            size="sm"
            variant={dateFilter === "today" ? "default" : "ghost"}
            onClick={() => setDateFilter("today")}
            className="text-xs h-8 gap-1"
          >
            <Calendar className="h-3.5 w-3.5" /> Today
          </Button>
          <Button
            size="sm"
            variant={dateFilter === "this_month" ? "default" : "ghost"}
            onClick={() => setDateFilter("this_month")}
            className="text-xs h-8"
          >
            This Month
          </Button>
          <Button
            size="sm"
            variant={dateFilter === "all" ? "default" : "ghost"}
            onClick={() => setDateFilter("all")}
            className="text-xs h-8"
          >
            All Logs
          </Button>
        </div>
      </div>

      {/* Data Table */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-xs overflow-hidden">
        {isLoading ? (
          <div className="p-6 space-y-4">
            <Skeleton className="h-8 w-full" />
            <Skeleton className="h-12 w-full" />
            <Skeleton className="h-12 w-full" />
            <Skeleton className="h-12 w-full" />
          </div>
        ) : mergedAttendanceList.length === 0 ? (
          <div className="p-12 text-center text-slate-500">
            <p className="text-base font-semibold text-slate-700">No personnel records found</p>
          </div>
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Employee Details</TableHead>
                <TableHead>Check-In Time</TableHead>
                <TableHead>Check-Out Time</TableHead>
                <TableHead>Location / Coordinates</TableHead>
                <TableHead>Check-in Selfie</TableHead>
                <TableHead>Status</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {mergedAttendanceList.map((row) => (
                <TableRow key={row.id} className="hover:bg-slate-50/80">
                  <TableCell className="font-semibold text-slate-900">
                    <div className="flex items-center gap-3">
                      <div className={`flex h-9 w-9 items-center justify-center rounded-full font-bold text-xs ${
                        row.isCheckedIn ? "bg-emerald-100 text-emerald-800" : "bg-rose-100 text-rose-800"
                      }`}>
                        {row.name ? row.name.charAt(0).toUpperCase() : "E"}
                      </div>
                      <div>
                        <p className="leading-tight text-slate-900">{row.name}</p>
                        <p className="text-xs text-slate-500 font-mono font-normal flex items-center gap-1.5 mt-0.5">
                          <span className="font-semibold text-slate-700">{row.employee_code}</span>
                          <span>•</span>
                          <span>{row.designation}</span>
                          {row.department && (
                            <span className="text-slate-400">({row.department})</span>
                          )}
                        </p>
                      </div>
                    </div>
                  </TableCell>

                  <TableCell className="text-xs font-mono text-slate-700">
                    {row.isCheckedIn && row.checkInTime ? (
                      <span className="flex items-center gap-1.5 font-medium text-slate-900">
                        <Clock className="h-3.5 w-3.5 text-emerald-600" />
                        {new Date(row.checkInTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                      </span>
                    ) : (
                      <span className="text-slate-400">—</span>
                    )}
                  </TableCell>

                  <TableCell className="text-xs font-mono text-slate-500">
                    {row.isCheckedIn ? (
                      row.checkOutTime ? (
                        new Date(row.checkOutTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
                      ) : (
                        <Badge variant="secondary" className="text-[10px] bg-blue-50 text-blue-700 border-blue-200">
                          Active On Duty
                        </Badge>
                      )
                    ) : (
                      <span className="text-slate-400">—</span>
                    )}
                  </TableCell>

                  <TableCell className="text-xs font-mono text-slate-600">
                    {row.checkInLat && row.checkInLng ? (
                      <a
                        href={`https://maps.google.com/?q=${row.checkInLat},${row.checkInLng}`}
                        target="_blank"
                        rel="noreferrer"
                        className="inline-flex items-center gap-1 text-blue-600 hover:underline"
                      >
                        <MapPin className="h-3.5 w-3.5 text-blue-500" />
                        {row.checkInLat.toFixed(4)}, {row.checkInLng.toFixed(4)}
                      </a>
                    ) : row.address ? (
                      <span className="text-slate-600 truncate max-w-xs inline-block" title={row.address}>
                        {row.address}
                      </span>
                    ) : (
                      <span className="text-slate-400">—</span>
                    )}
                  </TableCell>

                  <TableCell>
                    {row.selfieUrl ? (
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => setSelectedPhoto(row.selfieUrl)}
                        className="gap-1.5 text-xs text-slate-700 hover:text-blue-600"
                      >
                        <Camera className="h-3.5 w-3.5 text-slate-500" /> View Selfie
                      </Button>
                    ) : (
                      <span className="text-xs text-slate-400">No Photo</span>
                    )}
                  </TableCell>

                  <TableCell>
                    {row.isCheckedIn ? (
                      <div className="flex items-center gap-1.5">
                        <Badge variant="success" className="gap-1">
                          <CheckCircle2 className="h-3 w-3" /> Present
                        </Badge>
                        {row.wfh && (
                          <Badge variant="secondary" className="text-[10px] bg-purple-50 text-purple-700 border-purple-200">
                            WFH
                          </Badge>
                        )}
                        {row.onDuty && (
                          <Badge variant="secondary" className="text-[10px] bg-amber-50 text-amber-700 border-amber-200">
                            <Briefcase className="h-3 w-3 mr-0.5" /> On Duty
                          </Badge>
                        )}
                      </div>
                    ) : (
                      <Badge variant="destructive" className="gap-1">
                        <XCircle className="h-3 w-3" /> Not Checked In
                      </Badge>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </div>

      {/* Selfie High-Res Modal */}
      {selectedPhoto && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl p-4 max-w-md w-full shadow-2xl space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="font-semibold text-slate-900 text-sm">Selfie Check-in Audit</h3>
              <Button variant="ghost" size="sm" onClick={() => setSelectedPhoto(null)}>
                ✕
              </Button>
            </div>

            <div className="relative bg-slate-100 rounded-lg overflow-hidden flex items-center justify-center border min-h-[250px]">
              <img
                src={selectedPhoto}
                alt="Check-in Selfie"
                className="rounded-lg w-full h-80 object-cover"
                onError={(e) => {
                  // Fallback for non-image files or file loading error
                  (e.target as HTMLElement).style.display = "none";
                  const fallback = document.getElementById("selfie-fallback");
                  if (fallback) fallback.style.display = "flex";
                }}
              />
              <div id="selfie-fallback" className="hidden flex-col items-center justify-center p-6 text-center space-y-2">
                <Camera className="h-10 w-10 text-slate-400" />
                <p className="text-xs text-slate-600 font-medium">Selfie file uploaded as document/text</p>
                <a
                  href={selectedPhoto}
                  target="_blank"
                  rel="noreferrer"
                  className="inline-flex items-center gap-1 text-xs text-blue-600 font-semibold hover:underline"
                >
                  Open Original File <ExternalLink className="h-3 w-3" />
                </a>
              </div>
            </div>

            <div className="flex gap-2">
              <a
                href={selectedPhoto}
                target="_blank"
                rel="noreferrer"
                className="flex-1 inline-flex items-center justify-center gap-1.5 text-xs font-semibold py-2 rounded-lg border border-slate-300 text-slate-700 hover:bg-slate-50"
              >
                Open Full Window <ExternalLink className="h-3.5 w-3.5" />
              </a>
              <Button variant="secondary" className="flex-1" onClick={() => setSelectedPhoto(null)}>
                Close Audit
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
