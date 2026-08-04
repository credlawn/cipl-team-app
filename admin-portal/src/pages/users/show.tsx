import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useOne, useUpdate } from "@refinedev/core";
import {
  ArrowLeft,
  Save,
  User,
  Briefcase,
  Smartphone,
  FileText,
  Mail,
  Phone,
  AlertCircle,
  ExternalLink,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { pb, POCKETBASE_URL } from "@/lib/pocketbase";

export const UserFormPage = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<"general" | "controls" | "device">("general");

  const { data, isLoading, refetch } = useOne({
    resource: "users",
    id: id || "",
  });

  const { mutate: updateUser, isLoading: isUpdating } = useUpdate();
  const user = data?.data;

  // Form state
  const [editForm, setEditForm] = useState<any>({});

  useEffect(() => {
    if (user) {
      setEditForm({
        employee_name: user.employee_name || "",
        mobile_no: user.mobile_no || "",
        role: user.role || "Employee",
        designation: user.designation || "",
        department: user.department || "",
        vertical: user.vertical || "",
        salary: user.salary || "",
        office_start_time: user.office_start_time || "",
        office_end_time: user.office_end_time || "",
        disabled: !!user.disabled,
        wfh: !!user.wfh,
        no_atn: !!user.no_atn,
        on_duty: !!user.on_duty,
        stop_auto_leads: !!user.stop_auto_leads,
        stop_fcm_notification: !!user.stop_fcm_notification,
        must_change_password: !!user.must_change_password,
        bh_access: !!user.bh_access,
      });
    }
  }, [user]);

  const handleSaveForm = () => {
    if (!id) return;
    updateUser(
      {
        resource: "users",
        id,
        values: editForm,
      },
      {
        onSuccess: () => {
          refetch();
        },
      }
    );
  };

  if (isLoading) {
    return (
      <div className="p-6 space-y-4">
        <Skeleton className="h-10 w-48" />
        <Skeleton className="h-24 w-full" />
        <Skeleton className="h-64 w-full" />
      </div>
    );
  }

  if (!user) {
    return (
      <div className="p-12 text-center space-y-4">
        <AlertCircle className="h-12 w-12 text-rose-500 mx-auto" />
        <h2 className="text-xl font-bold text-slate-800">Personnel Record Not Found</h2>
        <Button onClick={() => navigate("/users")}>Back to Directory</Button>
      </div>
    );
  }

  const avatarUrl = user.avatar ? pb.files.getUrl(user, user.avatar) : null;
  const name = user.employee_name || user.email || "Employee Profile";

  return (
    <div className="space-y-6 max-w-7xl mx-auto pb-12">
      {/* Clean ERP Action Topbar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-4 rounded-xl border border-slate-200 shadow-2xs">
        <div className="flex items-center gap-3">
          <Button
            variant="outline"
            size="sm"
            onClick={() => navigate("/users")}
            className="gap-1.5 text-slate-700 hover:text-slate-900"
          >
            <ArrowLeft className="h-4 w-4 text-slate-500" /> Back to Team List
          </Button>
          <div className="h-4 w-px bg-slate-200 hidden sm:block" />
          <p className="text-xs text-slate-500 font-mono">
            Form View • ID: <span className="font-semibold text-slate-800">{user.employee_code || user.id}</span>
          </p>
        </div>

        {/* Topbar Actions */}
        <div className="flex items-center gap-2">
          <Button variant="outline" onClick={() => navigate("/users")}>
            Cancel
          </Button>
          <Button
            onClick={handleSaveForm}
            disabled={isUpdating}
            className="bg-blue-600 hover:bg-blue-700 text-white font-bold gap-2 shadow-2xs"
          >
            <Save className="h-4 w-4" /> {isUpdating ? "Saving Changes..." : "Save Record"}
          </Button>
        </div>
      </div>

      {/* Clean Professional ERP Header Card (White / Subtle Slate) */}
      <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-2xs flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
        <div className="flex items-center gap-4">
          {avatarUrl ? (
            <img src={avatarUrl} alt={name} className="h-16 w-16 rounded-xl object-cover border border-slate-200 shadow-2xs" />
          ) : (
            <div className="flex h-16 w-16 items-center justify-center rounded-xl bg-slate-100 text-slate-700 font-bold text-2xl border border-slate-200">
              {name.charAt(0).toUpperCase()}
            </div>
          )}
          <div>
            <div className="flex items-center gap-2.5">
              <h2 className="text-xl font-bold tracking-tight text-slate-900">{name}</h2>
              {user.disabled ? (
                <Badge variant="destructive">Inactive</Badge>
              ) : (
                <Badge variant="success">Active Staff</Badge>
              )}
              <Badge variant="secondary" className="capitalize">
                {user.role || "Employee"}
              </Badge>
            </div>
            <p className="text-xs text-slate-500 font-mono mt-1 flex flex-wrap items-center gap-2">
              <span className="font-semibold text-slate-700">{user.employee_code || user.id}</span>
              <span>•</span>
              <span>{user.designation || "Executive"}</span>
              {user.department && (
                <>
                  <span>•</span>
                  <span>{user.department}</span>
                </>
              )}
            </p>
            <div className="flex flex-wrap items-center gap-3 mt-2 text-xs font-mono text-slate-600">
              <span className="flex items-center gap-1">
                <Mail className="h-3.5 w-3.5 text-slate-400" /> {user.email || "No Email"}
              </span>
              {user.mobile_no && (
                <span className="flex items-center gap-1">
                  <Phone className="h-3.5 w-3.5 text-slate-400" /> {user.mobile_no}
                </span>
              )}
            </div>
          </div>
        </div>

        <div className="flex flex-row md:flex-col gap-3 text-xs font-mono text-slate-600 bg-slate-50 p-4 rounded-lg border border-slate-200 w-full md:w-auto">
          <div>
            <span className="text-slate-400 font-sans block text-[11px] font-semibold">Date of Joining</span>
            <span className="text-slate-900 font-semibold">{user.date_of_joining ? new Date(user.date_of_joining).toLocaleDateString() : "—"}</span>
          </div>
          <div>
            <span className="text-slate-400 font-sans block text-[11px] font-semibold">Paid Leave Balance</span>
            <span className="text-slate-900 font-bold">{user.paid_leave_balance ?? "0"} Days</span>
          </div>
        </div>
      </div>

      {/* Clean Segmented Navigation Tabs */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-2xs p-1 flex gap-1">
        <button
          onClick={() => setActiveTab("general")}
          className={`flex-1 py-2 px-4 rounded-lg text-xs font-semibold transition-all ${
            activeTab === "general"
              ? "bg-slate-900 text-white shadow-2xs"
              : "text-slate-600 hover:text-slate-900 hover:bg-slate-50"
          }`}
        >
          1. General & HR Profile Form
        </button>
        <button
          onClick={() => setActiveTab("controls")}
          className={`flex-1 py-2 px-4 rounded-lg text-xs font-semibold transition-all ${
            activeTab === "controls"
              ? "bg-slate-900 text-white shadow-2xs"
              : "text-slate-600 hover:text-slate-900 hover:bg-slate-50"
          }`}
        >
          2. Work Mode & System Controls
        </button>
        <button
          onClick={() => setActiveTab("device")}
          className={`flex-1 py-2 px-4 rounded-lg text-xs font-semibold transition-all ${
            activeTab === "device"
              ? "bg-slate-900 text-white shadow-2xs"
              : "text-slate-600 hover:text-slate-900 hover:bg-slate-50"
          }`}
        >
          3. Mobile Device Telemetry
        </button>
      </div>

      {/* Clean Form Content Canvas */}
      {activeTab === "general" && (
        <div className="space-y-6">
          {/* Card 1: Personal & Position Info */}
          <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-2xs space-y-4">
            <h3 className="text-xs font-bold uppercase tracking-wider text-slate-500 flex items-center gap-2">
              <User className="h-4 w-4 text-slate-400" /> Personal & Designation Details
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
              <div>
                <label className="text-xs font-semibold text-slate-700">Employee Full Name</label>
                <Input
                  value={editForm.employee_name}
                  onChange={(e) => setEditForm({ ...editForm, employee_name: e.target.value })}
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-xs font-semibold text-slate-700">Mobile Phone Number</label>
                <Input
                  value={editForm.mobile_no}
                  onChange={(e) => setEditForm({ ...editForm, mobile_no: e.target.value })}
                  className="mt-1 font-mono"
                />
              </div>
              <div>
                <label className="text-xs font-semibold text-slate-700">System Role</label>
                <select
                  value={editForm.role}
                  onChange={(e) => setEditForm({ ...editForm, role: e.target.value })}
                  className="mt-1 h-10 w-full rounded-lg border border-slate-300 bg-white px-3 text-sm text-slate-900 font-medium"
                >
                  <option value="Admin">Admin</option>
                  <option value="Manager">Manager</option>
                  <option value="Employee">Employee</option>
                </select>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-5 pt-2">
              <div>
                <label className="text-xs font-semibold text-slate-700">Designation</label>
                <Input
                  value={editForm.designation}
                  onChange={(e) => setEditForm({ ...editForm, designation: e.target.value })}
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-xs font-semibold text-slate-700">Department</label>
                <Input
                  value={editForm.department}
                  onChange={(e) => setEditForm({ ...editForm, department: e.target.value })}
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-xs font-semibold text-slate-700">Vertical</label>
                <Input
                  value={editForm.vertical}
                  onChange={(e) => setEditForm({ ...editForm, vertical: e.target.value })}
                  className="mt-1"
                />
              </div>
            </div>
          </div>

          {/* Card 2: Duty Timings & Compensation */}
          <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-2xs space-y-4">
            <h3 className="text-xs font-bold uppercase tracking-wider text-slate-500 flex items-center gap-2">
              <Briefcase className="h-4 w-4 text-slate-400" /> Duty Hours & Compensation
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
              <div>
                <label className="text-xs font-semibold text-slate-700">Office Start Time</label>
                <Input
                  value={editForm.office_start_time}
                  onChange={(e) => setEditForm({ ...editForm, office_start_time: e.target.value })}
                  className="mt-1"
                  placeholder="09:30 AM"
                />
              </div>
              <div>
                <label className="text-xs font-semibold text-slate-700">Office End Time</label>
                <Input
                  value={editForm.office_end_time}
                  onChange={(e) => setEditForm({ ...editForm, office_end_time: e.target.value })}
                  className="mt-1"
                  placeholder="06:30 PM"
                />
              </div>
              <div>
                <label className="text-xs font-semibold text-slate-700">Salary</label>
                <Input
                  value={editForm.salary}
                  onChange={(e) => setEditForm({ ...editForm, salary: e.target.value })}
                  className="mt-1 font-mono"
                />
              </div>
            </div>
          </div>

          {/* Aadhar Uploaded Files */}
          {user.aadhar_card && user.aadhar_card.length > 0 && (
            <div className="bg-slate-50 p-6 rounded-xl border border-slate-200 space-y-3">
              <h3 className="text-xs font-bold uppercase tracking-wider text-slate-700 flex items-center gap-2">
                <FileText className="h-4 w-4 text-slate-500" /> Aadhar Identity Verification Documents
              </h3>
              <div className="flex flex-wrap gap-3">
                {user.aadhar_card.map((file: string, idx: number) => {
                  const docUrl = `${POCKETBASE_URL}/api/files/users/${user.id}/${file}`;
                  return (
                    <a
                      key={idx}
                      href={docUrl}
                      target="_blank"
                      rel="noreferrer"
                      className="text-xs px-4 py-2 bg-white text-slate-700 rounded-lg border border-slate-300 hover:bg-slate-100 transition-colors inline-flex items-center gap-2 font-semibold font-mono shadow-2xs"
                    >
                      <FileText className="h-4 w-4 text-slate-500" /> Aadhar Document #{idx + 1} <ExternalLink className="h-3 w-3 text-slate-400" />
                    </a>
                  );
                })}
              </div>
            </div>
          )}
        </div>
      )}

      {/* Tab 2: System Toggles */}
      {activeTab === "controls" && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
          <div className="bg-white p-5 rounded-xl border border-slate-200 flex items-center justify-between shadow-2xs">
            <div>
              <p className="text-base font-bold text-slate-900">Work From Home (WFH)</p>
              <p className="text-xs text-slate-500">Allow remote attendance check-in</p>
            </div>
            <input
              type="checkbox"
              checked={editForm.wfh}
              onChange={(e) => setEditForm({ ...editForm, wfh: e.target.checked })}
              className="h-5 w-5 rounded border-slate-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
            />
          </div>

          <div className="bg-white p-5 rounded-xl border border-slate-200 flex items-center justify-between shadow-2xs">
            <div>
              <p className="text-base font-bold text-slate-900">On Duty Status</p>
              <p className="text-xs text-slate-500">Mark employee on active duty assignment</p>
            </div>
            <input
              type="checkbox"
              checked={editForm.on_duty}
              onChange={(e) => setEditForm({ ...editForm, on_duty: e.target.checked })}
              className="h-5 w-5 rounded border-slate-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
            />
          </div>

          <div className="bg-white p-5 rounded-xl border border-rose-200 bg-rose-50/20 flex items-center justify-between shadow-2xs">
            <div>
              <p className="text-base font-bold text-rose-900">Account Disabled / Inactive</p>
              <p className="text-xs text-rose-600">Prevent system login & app authentication</p>
            </div>
            <input
              type="checkbox"
              checked={editForm.disabled}
              onChange={(e) => setEditForm({ ...editForm, disabled: e.target.checked })}
              className="h-5 w-5 rounded border-rose-300 text-rose-600 focus:ring-rose-500 cursor-pointer"
            />
          </div>

          <div className="bg-white p-5 rounded-xl border border-slate-200 flex items-center justify-between shadow-2xs">
            <div>
              <p className="text-base font-bold text-slate-900">Exempt Attendance (no_atn)</p>
              <p className="text-xs text-slate-500">Exclude from daily check-in tracking</p>
            </div>
            <input
              type="checkbox"
              checked={editForm.no_atn}
              onChange={(e) => setEditForm({ ...editForm, no_atn: e.target.checked })}
              className="h-5 w-5 rounded border-slate-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
            />
          </div>

          <div className="bg-white p-5 rounded-xl border border-slate-200 flex items-center justify-between shadow-2xs">
            <div>
              <p className="text-base font-bold text-slate-900">Stop Auto Lead Re-allocation</p>
              <p className="text-xs text-slate-500">Prevent cron from shuffling leads</p>
            </div>
            <input
              type="checkbox"
              checked={editForm.stop_auto_leads}
              onChange={(e) => setEditForm({ ...editForm, stop_auto_leads: e.target.checked })}
              className="h-5 w-5 rounded border-slate-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
            />
          </div>

          <div className="bg-white p-5 rounded-xl border border-slate-200 flex items-center justify-between shadow-2xs">
            <div>
              <p className="text-base font-bold text-slate-900">Stop FCM Push Notifications</p>
              <p className="text-xs text-slate-500">Block push notifications on mobile</p>
            </div>
            <input
              type="checkbox"
              checked={editForm.stop_fcm_notification}
              onChange={(e) => setEditForm({ ...editForm, stop_fcm_notification: e.target.checked })}
              className="h-5 w-5 rounded border-slate-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
            />
          </div>
        </div>
      )}

      {/* Tab 3: Device Telemetry */}
      {activeTab === "device" && (
        <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-2xs space-y-5">
          <h3 className="text-xs font-bold uppercase tracking-wider text-slate-500 flex items-center gap-2">
            <Smartphone className="h-4 w-4 text-slate-400" /> Mobile Hardware & App Diagnostics
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-5 text-xs font-mono">
            <div className="p-4 bg-slate-50 rounded-lg border border-slate-200">
              <span className="text-slate-400 block text-[11px] font-sans font-semibold">Device Model</span>
              <span className="text-slate-900 font-bold text-sm">{user.device_model || "Not Registered"}</span>
            </div>
            <div className="p-4 bg-slate-50 rounded-lg border border-slate-200">
              <span className="text-slate-400 block text-[11px] font-sans font-semibold">Android / OS Version</span>
              <span className="text-slate-900 font-bold text-sm">{user.android_version || "Not Registered"}</span>
            </div>
            <div className="p-4 bg-slate-50 rounded-lg border border-slate-200">
              <span className="text-slate-400 block text-[11px] font-sans font-semibold">App Build Version</span>
              <span className="text-slate-900 font-bold text-sm">{user.app_version || "Not Registered"}</span>
            </div>
            <div className="p-4 bg-slate-50 rounded-lg border border-slate-200">
              <span className="text-slate-400 block text-[11px] font-sans font-semibold">Device Unique Hardware ID</span>
              <span className="text-slate-900 font-bold truncate block">{user.device_id || "Not Registered"}</span>
            </div>
          </div>

          <div className="p-4 bg-slate-50 rounded-lg border border-slate-200 text-xs font-mono">
            <span className="text-slate-400 block text-[11px] font-sans font-semibold">FCM Push Notification Token</span>
            <span className="text-slate-800 break-all">{user.fcm_token || "None"}</span>
          </div>

          <div className="p-4 bg-slate-50 rounded-lg border border-slate-200 text-xs">
            <span className="text-slate-400 block text-[11px] font-sans font-semibold">App Permission Status</span>
            <p className="text-slate-700 mt-1">{user.app_permission_status || "Standard permissions granted"}</p>
          </div>
        </div>
      )}
    </div>
  );
};
