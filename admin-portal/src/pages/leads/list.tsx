import { useState } from "react";
import { useList, useUpdate } from "@refinedev/core";
import { Search, Filter, Eye, UserCheck, Phone, RefreshCw, ChevronLeft, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { Skeleton } from "@/components/ui/skeleton";

export const LeadListPage = () => {
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [selectedLead, setSelectedLead] = useState<any>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const pageSize = 15;

  const filters: any[] = [];
  if (searchQuery) {
    filters.push({ field: "customer_name", operator: "contains", value: searchQuery });
  }
  if (statusFilter !== "all") {
    filters.push({ field: "status", operator: "eq", value: statusFilter });
  }

  const { data, isLoading, refetch } = useList({
    resource: "leads",
    pagination: { current: currentPage, pageSize },
    filters,
    sorters: [{ field: "created", order: "desc" }],
    meta: { expand: "assigned_to" },
  });

  const { mutate: updateLead, isLoading: isUpdating } = useUpdate();

  const leads = data?.data || [];
  const total = data?.total || 0;
  const totalPages = Math.ceil(total / pageSize) || 1;

  const getStatusBadge = (status: string) => {
    const s = status?.toLowerCase() || "";
    if (s.includes("approved") || s.includes("closed") || s.includes("converted")) {
      return <Badge variant="success">Approved</Badge>;
    }
    if (s.includes("in_progress") || s.includes("followup")) {
      return <Badge variant="warning">In Progress</Badge>;
    }
    if (s.includes("reject")) {
      return <Badge variant="destructive">Rejected</Badge>;
    }
    return <Badge variant="default">New Lead</Badge>;
  };

  return (
    <div className="space-y-6">
      {/* Header & Actions */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Lead Operations</h1>
          <p className="text-sm text-slate-500">Manage sales allocations, customer leads, and workflow statuses.</p>
        </div>
        <Button onClick={() => refetch()} variant="outline" className="gap-2">
          <RefreshCw className="h-4 w-4" /> Refresh Data
        </Button>
      </div>

      {/* Filter & Search Bar */}
      <div className="flex flex-col sm:flex-row items-center gap-3 bg-white p-4 rounded-xl border border-slate-200 shadow-xs">
        <div className="relative flex-1 w-full">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
          <Input
            placeholder="Search by customer name, mobile..."
            value={searchQuery}
            onChange={(e) => {
              setSearchQuery(e.target.value);
              setCurrentPage(1);
            }}
            className="pl-9"
          />
        </div>

        <div className="flex items-center gap-2 w-full sm:w-auto">
          <Filter className="h-4 w-4 text-slate-500 hidden sm:block" />
          <select
            value={statusFilter}
            onChange={(e) => {
              setStatusFilter(e.target.value);
              setCurrentPage(1);
            }}
            className="h-10 rounded-lg border border-slate-300 bg-white px-3 text-sm text-slate-700 focus:outline-none focus:ring-2 focus:ring-blue-500 w-full sm:w-44"
          >
            <option value="all">All Statuses</option>
            <option value="NEW">New</option>
            <option value="IN_PROGRESS">In Progress</option>
            <option value="APPROVED">Approved</option>
            <option value="REJECTED">Rejected</option>
          </select>
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
        ) : leads.length === 0 ? (
          <div className="p-12 text-center text-slate-500">
            <p className="text-base font-semibold text-slate-700">No leads found</p>
            <p className="text-xs mt-1">Try adjusting your search query or filters.</p>
          </div>
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Customer Name</TableHead>
                <TableHead>Mobile Number</TableHead>
                <TableHead>Assigned Employee</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Created Date</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {leads.map((lead: any) => (
                <TableRow key={lead.id} className="hover:bg-slate-50/80">
                  <TableCell className="font-semibold text-slate-900">
                    {lead.customer_name || lead.name || "N/A"}
                  </TableCell>
                  <TableCell className="text-slate-600 font-mono text-xs flex items-center gap-1.5">
                    <Phone className="h-3.5 w-3.5 text-slate-400" />
                    {lead.mobile || lead.phone || "—"}
                  </TableCell>
                  <TableCell>
                    {lead.expand?.assigned_to ? (
                      <span className="inline-flex items-center gap-1.5 text-xs font-medium text-slate-700">
                        <UserCheck className="h-3.5 w-3.5 text-blue-600" />
                        {lead.expand.assigned_to.name || lead.expand.assigned_to.email}
                      </span>
                    ) : (
                      <span className="text-xs text-slate-400 font-italic">Unassigned</span>
                    )}
                  </TableCell>
                  <TableCell>{getStatusBadge(lead.status)}</TableCell>
                  <TableCell className="text-xs text-slate-500">
                    {lead.created ? new Date(lead.created).toLocaleDateString() : "—"}
                  </TableCell>
                  <TableCell className="text-right">
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setSelectedLead(lead)}
                      className="gap-1 text-blue-600 hover:text-blue-800 hover:bg-blue-50"
                    >
                      <Eye className="h-4 w-4" /> View Details
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}

        {/* Pagination Footer */}
        <div className="flex items-center justify-between px-6 py-4 border-t border-slate-200 bg-slate-50/50">
          <span className="text-xs text-slate-500 font-medium">
            Showing Page {currentPage} of {totalPages} ({total} Total Records)
          </span>
          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              size="sm"
              disabled={currentPage === 1}
              onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
            >
              <ChevronLeft className="h-4 w-4" /> Previous
            </Button>
            <Button
              variant="outline"
              size="sm"
              disabled={currentPage >= totalPages}
              onClick={() => setCurrentPage((p) => p + 1)}
            >
              Next <ChevronRight className="h-4 w-4" />
            </Button>
          </div>
        </div>
      </div>

      {/* Side Drawer Modal for Lead Details */}
      {selectedLead && (
        <div className="fixed inset-0 z-50 flex justify-end bg-black/40 backdrop-blur-xs">
          <div className="w-full max-w-md bg-white h-full shadow-2xl p-6 overflow-y-auto flex flex-col justify-between">
            <div className="space-y-6">
              <div className="flex items-center justify-between border-b border-slate-200 pb-4">
                <h2 className="text-lg font-bold text-slate-900">Lead Detail View</h2>
                <Button variant="ghost" size="sm" onClick={() => setSelectedLead(null)}>
                  ✕
                </Button>
              </div>

              <div className="space-y-3">
                <div>
                  <label className="text-xs font-semibold text-slate-400 uppercase">Customer Name</label>
                  <p className="text-base font-bold text-slate-900">{selectedLead.customer_name || selectedLead.name}</p>
                </div>
                <div>
                  <label className="text-xs font-semibold text-slate-400 uppercase">Mobile Number</label>
                  <p className="text-sm font-mono text-slate-700">{selectedLead.mobile || selectedLead.phone || "N/A"}</p>
                </div>
                <div>
                  <label className="text-xs font-semibold text-slate-400 uppercase">Status</label>
                  <div className="mt-1">{getStatusBadge(selectedLead.status)}</div>
                </div>
                <div>
                  <label className="text-xs font-semibold text-slate-400 uppercase">Assigned To</label>
                  <p className="text-sm font-medium text-slate-800">
                    {selectedLead.expand?.assigned_to?.name || "Unassigned"}
                  </p>
                </div>
              </div>

              {/* Status Update Controls */}
              <div className="border-t border-slate-200 pt-4 space-y-3">
                <label className="text-xs font-semibold text-slate-700">Update Lead Status</label>
                <div className="grid grid-cols-2 gap-2">
                  <Button
                    size="sm"
                    variant="outline"
                    disabled={isUpdating}
                    onClick={() => {
                      updateLead({ resource: "leads", id: selectedLead.id, values: { status: "APPROVED" } });
                      setSelectedLead(null);
                    }}
                    className="border-emerald-200 text-emerald-700 hover:bg-emerald-50"
                  >
                    Mark Approved
                  </Button>
                  <Button
                    size="sm"
                    variant="outline"
                    disabled={isUpdating}
                    onClick={() => {
                      updateLead({ resource: "leads", id: selectedLead.id, values: { status: "REJECTED" } });
                      setSelectedLead(null);
                    }}
                    className="border-rose-200 text-rose-700 hover:bg-rose-50"
                  >
                    Mark Rejected
                  </Button>
                </div>
              </div>
            </div>

            <div className="pt-6">
              <Button variant="secondary" className="w-full" onClick={() => setSelectedLead(null)}>
                Close Panel
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
