import { Link, useLocation } from "react-router-dom";
import {
  LayoutDashboard,
  Users,
  Briefcase,
  Clock,
  PhoneCall,
} from "lucide-react";
import { cn } from "@/lib/utils";

const navigation = [
  { name: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
  { name: "Lead Operations", href: "/leads", icon: Briefcase },
  { name: "Team & Personnel", href: "/users", icon: Users },
  { name: "Attendance & Geo Logs", href: "/attendance", icon: Clock },
  { name: "Call Analytics", href: "/call-logs", icon: PhoneCall },
];

export const Sidebar = () => {
  const location = useLocation();

  return (
    <aside className="w-64 border-r border-slate-200 bg-slate-900 text-white flex flex-col justify-between min-h-screen">
      <div>
        {/* Brand Header */}
        <div className="flex h-16 items-center gap-3 border-b border-slate-800 px-6">
          <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-600 font-bold text-white shadow-md">
            C
          </div>
          <div>
            <h1 className="text-base font-bold tracking-tight text-white leading-none">
              Credlawn CRM
            </h1>
            <span className="text-[11px] font-medium text-blue-400 uppercase tracking-wider">
              Enterprise Admin
            </span>
          </div>
        </div>

        {/* Nav Links */}
        <nav className="space-y-1 px-3 py-6">
          {navigation.map((item) => {
            const isActive =
              location.pathname === item.href ||
              (item.href !== "/dashboard" && location.pathname.startsWith(item.href));

            return (
              <Link
                key={item.name}
                to={item.href}
                className={cn(
                  "flex items-center gap-3 rounded-lg px-3.5 py-2.5 text-sm font-medium transition-all duration-150",
                  isActive
                    ? "bg-blue-600 text-white shadow-sm font-semibold"
                    : "text-slate-400 hover:bg-slate-800 hover:text-slate-200"
                )}
              >
                <item.icon className={cn("h-4 w-4 shrink-0", isActive ? "text-white" : "text-slate-400")} />
                {item.name}
              </Link>
            );
          })}
        </nav>
      </div>

      {/* System Status Footer */}
      <div className="border-t border-slate-800 p-4 m-3 rounded-lg bg-slate-800/60">
        <div className="flex items-center gap-2 text-xs font-semibold text-emerald-400">
          <span className="h-2 w-2 rounded-full bg-emerald-400 animate-pulse" />
          System Online
        </div>
        <p className="mt-1 text-[11px] text-slate-400">
          Connected to PocketBase API v0.25
        </p>
      </div>
    </aside>
  );
};
