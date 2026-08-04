import { useState, useEffect } from "react";
import {
  X,
  User,
  Mail,
  Phone,
  Briefcase,
  Building2,
  Home,
  ShieldCheck,
  ShieldAlert,
  Calendar,
  CheckCircle2,
  XCircle,
  TrendingUp,
  TrendingDown,
  Clock,
  IdCard,
} from "lucide-react";
import { pb } from "@/lib/pocketbase";

export interface EmployeeOverviewStats {
  employee_code: string;
  employee_name: string;
  wfh?: boolean;
  designation?: string;
  is_checked_in?: boolean;
  today_ipa: number;
  today_ipd: number;
  yes_ipa: number;
  yes_ipd: number;
}

interface UserRecord {
  id: string;
  employee_code: string;
  employee_name?: string;
  name?: string;
  email?: string;
  mobile_number?: string;
  mobile?: string;
  phone?: string;
  role?: string;
  designation?: string;
  vertical?: string;
  wfh?: boolean;
  disabled?: boolean;
  no_atn?: boolean;
  on_duty?: boolean;
  created?: string;
  updated?: string;
  avatar?: string;
}

interface EmployeeDetailModalProps {
  employee: EmployeeOverviewStats | null;
  onClose: () => void;
}

export default function EmployeeDetailModal({ employee, onClose }: EmployeeDetailModalProps) {
  const [userRecord, setUserRecord] = useState<UserRecord | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!employee) return;

    let isMounted = true;
    setLoading(true);
    setError(null);

    // Fetch full user record from PocketBase users collection by employee_code
    pb.collection("users")
      .getFirstListItem(`employee_code = "${employee.employee_code}"`)
      .then((record) => {
        if (isMounted) {
          setUserRecord(record as unknown as UserRecord);
        }
      })
      .catch((err) => {
        console.warn("Could not fetch user record by employee_code:", err);
        if (isMounted) {
          setError("User details not found in database");
        }
      })
      .finally(() => {
        if (isMounted) setLoading(false);
      });

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    window.addEventListener("keydown", handleKeyDown);

    return () => {
      isMounted = false;
      window.removeEventListener("keydown", handleKeyDown);
    };
  }, [employee, onClose]);

  if (!employee) return null;

  // Resolved fields with fallbacks
  const displayName = userRecord?.employee_name || userRecord?.name || employee.employee_name;
  const email = userRecord?.email || "N/A";
  const mobile = userRecord?.mobile_number || userRecord?.mobile || userRecord?.phone || "N/A";
  const role = userRecord?.role || "Employee";
  const designation = userRecord?.designation || employee.designation || "Not specified";
  const vertical = userRecord?.vertical || "Credit Card";
  const isWFH = userRecord?.wfh ?? employee.wfh ?? false;
  const isDisabled = userRecord?.disabled ?? false;
  const isNoAtn = userRecord?.no_atn ?? false;
  const isOnDuty = userRecord?.on_duty ?? false;
  const createdDate = userRecord?.created
    ? new Date(userRecord.created).toLocaleDateString("en-IN", {
        day: "numeric",
        month: "short",
        year: "numeric",
      })
    : "N/A";

  // Calculations
  const todayTotal = employee.today_ipa + employee.today_ipd;
  const yesterdayTotal = employee.yes_ipa + employee.yes_ipd;
  const todayPct = todayTotal > 0 ? Math.round((employee.today_ipa / todayTotal) * 100) : 0;
  const yesPct = yesterdayTotal > 0 ? Math.round((employee.yes_ipa / yesterdayTotal) * 100) : 0;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/60 backdrop-blur-sm animate-in fade-in duration-200">
      {/* Click Backdrop to close */}
      <div className="absolute inset-0" onClick={onClose} />

      {/* Modal Container */}
      <div className="relative w-full max-w-2xl bg-white rounded-2xl shadow-2xl overflow-hidden border border-gray-100 max-h-[90vh] flex flex-col z-10">
        {/* Modal Header */}
        <div className="bg-gradient-to-r from-blue-700 via-blue-600 to-indigo-700 px-6 py-5 text-white relative">
          <button
            onClick={onClose}
            className="absolute top-4 right-4 p-1.5 rounded-full bg-white/10 hover:bg-white/20 text-white transition-colors cursor-pointer"
            title="Close"
          >
            <X className="w-5 h-5" />
          </button>

          <div className="flex items-center gap-4">
            {/* Avatar Initials */}
            <div className="w-14 h-14 rounded-2xl bg-white/15 backdrop-blur-md border border-white/20 flex items-center justify-center text-2xl font-bold text-white shadow-inner shrink-0">
              {displayName.charAt(0).toUpperCase()}
            </div>

            <div className="space-y-1">
              <div className="flex items-center gap-2">
                <h3 className="text-xl font-bold tracking-tight">{displayName}</h3>
                <span className="px-2 py-0.5 rounded-md bg-white/20 text-xs font-semibold uppercase tracking-wider text-blue-100">
                  {role}
                </span>
              </div>
              <div className="flex items-center gap-3 text-xs text-blue-100">
                <span className="flex items-center gap-1 font-mono">
                  <IdCard className="w-3.5 h-3.5 text-blue-200" />
                  {employee.employee_code}
                </span>
                <span>•</span>
                <span className="flex items-center gap-1">
                  <Briefcase className="w-3.5 h-3.5 text-blue-200" />
                  {designation}
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Modal Body */}
        <div className="p-6 space-y-6 overflow-y-auto">
          {loading ? (
            <div className="space-y-4 py-6">
              <div className="h-4 bg-gray-100 rounded animate-pulse w-3/4" />
              <div className="h-4 bg-gray-100 rounded animate-pulse w-1/2" />
              <div className="h-20 bg-gray-100 rounded-xl animate-pulse" />
            </div>
          ) : (
            <>
              {error && (
                <div className="p-3 bg-amber-50 border border-amber-200 text-amber-800 text-xs rounded-lg">
                  {error} - Displaying overview details.
                </div>
              )}

              {/* Status Badges Section */}
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
                {/* Attendance Status */}
                <div className="bg-gray-50 border border-gray-100 rounded-xl p-2.5 flex flex-col justify-between">
                  <span className="text-[11px] font-medium text-gray-400">Attendance</span>
                  <div className="mt-1 flex items-center gap-1.5">
                    {employee.is_checked_in ? (
                      <>
                        <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                        <span className="text-xs font-bold text-emerald-700">Checked In</span>
                      </>
                    ) : (
                      <>
                        <XCircle className="w-4 h-4 text-red-500" />
                        <span className="text-xs font-bold text-red-600">Absent</span>
                      </>
                    )}
                  </div>
                </div>

                {/* Work Location */}
                <div className="bg-gray-50 border border-gray-100 rounded-xl p-2.5 flex flex-col justify-between">
                  <span className="text-[11px] font-medium text-gray-400">Work Mode</span>
                  <div className="mt-1 flex items-center gap-1.5">
                    {isWFH ? (
                      <>
                        <Home className="w-4 h-4 text-emerald-600" />
                        <span className="text-xs font-bold text-emerald-700">WFH</span>
                      </>
                    ) : (
                      <>
                        <Building2 className="w-4 h-4 text-blue-600" />
                        <span className="text-xs font-bold text-blue-700">Office</span>
                      </>
                    )}
                  </div>
                </div>

                {/* On-Duty Status */}
                <div className="bg-gray-50 border border-gray-100 rounded-xl p-2.5 flex flex-col justify-between">
                  <span className="text-[11px] font-medium text-gray-400">Duty Status</span>
                  <div className="mt-1 flex items-center gap-1.5">
                    {isOnDuty ? (
                      <>
                        <Clock className="w-4 h-4 text-emerald-600" />
                        <span className="text-xs font-bold text-emerald-700">On Duty</span>
                      </>
                    ) : (
                      <>
                        <Clock className="w-4 h-4 text-gray-400" />
                        <span className="text-xs font-bold text-gray-600">Off Duty</span>
                      </>
                    )}
                  </div>
                </div>

                {/* Account Status */}
                <div className="bg-gray-50 border border-gray-100 rounded-xl p-2.5 flex flex-col justify-between">
                  <span className="text-[11px] font-medium text-gray-400">Account</span>
                  <div className="mt-1 flex items-center gap-1.5">
                    {!isDisabled ? (
                      <>
                        <ShieldCheck className="w-4 h-4 text-emerald-600" />
                        <span className="text-xs font-bold text-emerald-700">Active</span>
                      </>
                    ) : (
                      <>
                        <ShieldAlert className="w-4 h-4 text-red-500" />
                        <span className="text-xs font-bold text-red-600">Disabled</span>
                      </>
                    )}
                  </div>
                </div>
              </div>

              {/* Personal & Account Details Grid */}
              <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-3">
                <h4 className="text-xs font-bold text-gray-900 uppercase tracking-wider border-b border-gray-100 pb-2">
                  User Account Profile
                </h4>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
                  <div className="flex items-start gap-2.5">
                    <User className="w-4 h-4 text-gray-400 mt-0.5 shrink-0" />
                    <div>
                      <p className="text-gray-400">Full Name</p>
                      <p className="font-semibold text-gray-900">{displayName}</p>
                    </div>
                  </div>

                  <div className="flex items-start gap-2.5">
                    <IdCard className="w-4 h-4 text-gray-400 mt-0.5 shrink-0" />
                    <div>
                      <p className="text-gray-400">Employee Code</p>
                      <p className="font-semibold text-gray-900 font-mono">{employee.employee_code}</p>
                    </div>
                  </div>

                  <div className="flex items-start gap-2.5">
                    <Mail className="w-4 h-4 text-gray-400 mt-0.5 shrink-0" />
                    <div>
                      <p className="text-gray-400">Email Address</p>
                      <p className="font-semibold text-gray-900 select-all">{email}</p>
                    </div>
                  </div>

                  <div className="flex items-start gap-2.5">
                    <Phone className="w-4 h-4 text-gray-400 mt-0.5 shrink-0" />
                    <div>
                      <p className="text-gray-400">Mobile Number</p>
                      <p className="font-semibold text-gray-900">{mobile}</p>
                    </div>
                  </div>

                  <div className="flex items-start gap-2.5">
                    <Briefcase className="w-4 h-4 text-gray-400 mt-0.5 shrink-0" />
                    <div>
                      <p className="text-gray-400">Designation & Vertical</p>
                      <p className="font-semibold text-gray-900">
                        {designation} • <span className="text-blue-600">{vertical}</span>
                      </p>
                    </div>
                  </div>

                  <div className="flex items-start gap-2.5">
                    <Calendar className="w-4 h-4 text-gray-400 mt-0.5 shrink-0" />
                    <div>
                      <p className="text-gray-400">Joined / Created Date</p>
                      <p className="font-semibold text-gray-900">{createdDate}</p>
                    </div>
                  </div>
                </div>

                {isNoAtn && (
                  <div className="mt-2 pt-2 border-t border-gray-100 flex items-center gap-1.5 text-xs text-amber-700 bg-amber-50 p-2 rounded-lg">
                    <ShieldAlert className="w-4 h-4 shrink-0 text-amber-600" />
                    <span>This user is marked as <strong>Exempt from Attendance Tracking (no_atn)</strong>.</span>
                  </div>
                )}
              </div>

              {/* Performance Stats Cards */}
              <div className="bg-gray-50 rounded-xl border border-gray-200/80 p-4 space-y-3">
                <h4 className="text-xs font-bold text-gray-900 uppercase tracking-wider border-b border-gray-200/60 pb-2">
                  Performance Summary (IPA / IPD)
                </h4>

                <div className="grid grid-cols-2 gap-3">
                  {/* Today Stats */}
                  <div className="bg-white rounded-lg p-3 border border-gray-200 shadow-sm space-y-1">
                    <div className="flex items-center justify-between text-xs text-gray-500 font-medium">
                      <span>Today</span>
                      <span className="text-violet-600 font-semibold">{todayPct > 0 ? `${todayPct}% IPA` : "-"}</span>
                    </div>
                    <div className="flex items-baseline gap-3 pt-1">
                      <div>
                        <span className="text-xs text-emerald-600 font-medium">IPA</span>
                        <p className="text-lg font-bold text-emerald-700">{employee.today_ipa || "-"}</p>
                      </div>
                      <div>
                        <span className="text-xs text-red-600 font-medium">IPD</span>
                        <p className="text-lg font-bold text-red-700">{employee.today_ipd || "-"}</p>
                      </div>
                      <div className="ml-auto text-right">
                        <span className="text-xs text-blue-600 font-medium">Total</span>
                        <p className="text-lg font-bold text-blue-700">{todayTotal || "-"}</p>
                      </div>
                    </div>
                  </div>

                  {/* Yesterday Stats */}
                  <div className="bg-white rounded-lg p-3 border border-gray-200 shadow-sm space-y-1">
                    <div className="flex items-center justify-between text-xs text-gray-500 font-medium">
                      <span>Yesterday</span>
                      <span className="text-violet-600 font-semibold">{yesPct > 0 ? `${yesPct}% IPA` : "-"}</span>
                    </div>
                    <div className="flex items-baseline gap-3 pt-1">
                      <div>
                        <span className="text-xs text-gray-500 font-medium">IPA</span>
                        <p className="text-lg font-bold text-gray-700">{employee.yes_ipa || "-"}</p>
                      </div>
                      <div>
                        <span className="text-xs text-gray-500 font-medium">IPD</span>
                        <p className="text-lg font-bold text-gray-700">{employee.yes_ipd || "-"}</p>
                      </div>
                      <div className="ml-auto text-right">
                        <span className="text-xs text-gray-500 font-medium">Total</span>
                        <p className="text-lg font-bold text-gray-700">{yesterdayTotal || "-"}</p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Day-over-day Trend Indicator */}
                {(() => {
                  const diff = todayTotal - yesterdayTotal;
                  if (diff === 0) return null;
                  return (
                    <div className="flex items-center justify-center gap-1.5 text-xs pt-1 font-medium">
                      {diff > 0 ? (
                        <>
                          <TrendingUp className="w-4 h-4 text-emerald-600" />
                          <span className="text-emerald-700">Total volume is UP by +{diff} cases compared to yesterday</span>
                        </>
                      ) : (
                        <>
                          <TrendingDown className="w-4 h-4 text-red-600" />
                          <span className="text-red-700">Total volume is DOWN by {diff} cases compared to yesterday</span>
                        </>
                      )}
                    </div>
                  );
                })()}
              </div>
            </>
          )}
        </div>

        {/* Modal Footer */}
        <div className="px-6 py-3 bg-gray-50 border-t border-gray-100 flex items-center justify-end">
          <button
            onClick={onClose}
            className="px-4 py-2 text-xs font-semibold text-gray-700 bg-white border border-gray-300 rounded-lg shadow-sm hover:bg-gray-50 transition-colors cursor-pointer"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
}
