import { useList } from "@refinedev/core";
import { PhoneCall, Clock, RefreshCw, User } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { Skeleton } from "@/components/ui/skeleton";

export const CallLogListPage = () => {
  const { data, isLoading, refetch } = useList({
    resource: "call_logs",
    pagination: { pageSize: 50 },
    sorters: [{ field: "created", order: "desc" }],
    meta: { expand: "user_id, lead_id" },
  });

  const logs = data?.data || [];

  const formatDuration = (seconds: number) => {
    if (!seconds) return "0s";
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return mins > 0 ? `${mins}m ${secs}s` : `${secs}s`;
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Sales Call Analytics & Logs</h1>
          <p className="text-sm text-slate-500">Track customer call durations, call timestamps, and sales executive interactions.</p>
        </div>
        <Button onClick={() => refetch()} variant="outline" className="gap-2">
          <RefreshCw className="h-4 w-4" /> Refresh Call Logs
        </Button>
      </div>

      {/* Table */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-xs overflow-hidden">
        {isLoading ? (
          <div className="p-6 space-y-4">
            <Skeleton className="h-8 w-full" />
            <Skeleton className="h-12 w-full" />
            <Skeleton className="h-12 w-full" />
          </div>
        ) : logs.length === 0 ? (
          <div className="p-12 text-center text-slate-500">
            <p className="text-base font-semibold text-slate-700">No call logs recorded</p>
          </div>
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Caller Executive</TableHead>
                <TableHead>Customer / Lead</TableHead>
                <TableHead>Call Timestamp</TableHead>
                <TableHead>Duration</TableHead>
                <TableHead>Call Type</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {logs.map((log: any) => {
                const caller = log.expand?.user_id;
                const lead = log.expand?.lead_id;

                return (
                  <TableRow key={log.id} className="hover:bg-slate-50/80">
                    <TableCell className="font-semibold text-slate-900 flex items-center gap-2">
                      <User className="h-4 w-4 text-blue-600" />
                      {caller?.name || "Sales Executive"}
                    </TableCell>
                    <TableCell className="text-slate-700 font-mono text-xs">
                      {lead?.customer_name || log.customer_number || "Customer"}
                    </TableCell>
                    <TableCell className="text-xs font-mono text-slate-600">
                      {log.created ? new Date(log.created).toLocaleString() : "—"}
                    </TableCell>
                    <TableCell className="text-xs font-mono text-slate-900 font-bold">
                      <span className="inline-flex items-center gap-1">
                        <Clock className="h-3.5 w-3.5 text-slate-400" />
                        {formatDuration(log.duration || log.call_duration || 0)}
                      </span>
                    </TableCell>
                    <TableCell>
                      <Badge variant="secondary" className="gap-1">
                        <PhoneCall className="h-3 w-3 text-blue-600" /> Outgoing Followup
                      </Badge>
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
