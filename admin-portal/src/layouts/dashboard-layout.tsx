import { useState, useRef, useEffect } from "react";
import { NavLink, useLocation } from "react-router-dom";
import { useAuth } from "@/hooks/use-auth";
import { cn } from "@/lib/utils";
import {
  LayoutDashboard,
  Users,
  Database,
  Phone,
  CalendarCheck,
  Settings,
  LogOut,
  Layers,
  ChevronDown,
} from "lucide-react";

const navItems = [
  { to: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { to: "/employees", label: "Employees", icon: Users },
  { to: "/leads", label: "Leads", icon: Database },
  { to: "/call-logs", label: "Call Logs", icon: Phone },
  { to: "/attendance", label: "Attendance", icon: CalendarCheck },
  { to: "/settings", label: "Settings", icon: Settings },
];

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { user, logout } = useAuth();
  const location = useLocation();
  const [menuOpen, setMenuOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  const userName = (user?.name as string) || "Manager";
  const userRole = (user?.role as string) || "";

  useEffect(() => {
    function handleClick(e: MouseEvent) {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) {
        setMenuOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, []);

  return (
    <div className="min-h-screen bg-blue-50" style={{
      backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='104' viewBox='0 0 60 104' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' stroke='%239CA3AF' stroke-width='0.4' opacity='0.25'%3E%3Cpath d='M30 0L0 30V74L30 104'/%3E%3Cpath d='M30 0L60 30V74L30 104'/%3E%3Cpath d='M0 30L30 60L60 30'/%3E%3C/g%3E%3C/svg%3E")`,
      backgroundSize: '60px 104px'
    }}>

      {/* Top Navigation Bar */}
      <header className="sticky top-0 z-50 h-14 bg-white/95 backdrop-blur-sm border-b border-blue-100 shadow-sm">
        <div className="h-full px-4 flex items-center justify-between">
          {/* Left: Logo */}
          <div className="flex items-center gap-3">
            <div className="w-7 h-7 bg-gradient-to-br from-blue-600 to-blue-700 rounded-lg flex items-center justify-center shadow-sm shrink-0">
              <Layers className="w-3.5 h-3.5 text-white" />
            </div>
            <span className="text-sm font-bold text-gray-900 hidden sm:block">CLPB</span>

            {/* Desktop Nav */}
            <nav className="hidden md:flex items-center ml-6 gap-0.5">
              {navItems.map((item) => (
                <NavLink
                  key={item.to}
                  to={item.to}
                  className={({ isActive }) =>
                    cn(
                      "flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium transition-colors",
                      isActive
                        ? "bg-blue-50 text-blue-700"
                        : "text-gray-500 hover:text-gray-700 hover:bg-gray-100"
                    )
                  }
                >
                  <item.icon className="w-3.5 h-3.5" />
                  {item.label}
                </NavLink>
              ))}
            </nav>
          </div>

          {/* Right: User */}
          <div className="relative" ref={menuRef}>
            <button
              onClick={() => setMenuOpen(!menuOpen)}
              className="flex items-center gap-2 px-2 py-1.5 rounded-lg hover:bg-gray-100 transition-colors cursor-pointer"
            >
              <div className="w-7 h-7 bg-blue-100 rounded-full flex items-center justify-center">
                <span className="text-xs font-semibold text-blue-700">
                  {userName.charAt(0).toUpperCase()}
                </span>
              </div>
              <span className="text-xs font-medium text-gray-700 hidden sm:block">{userName}</span>
              <ChevronDown className="w-3 h-3 text-gray-400" />
            </button>

            {menuOpen && (
              <div className="absolute right-0 top-full mt-1 w-48 bg-white rounded-xl border border-gray-200 shadow-lg py-1 z-50">
                <div className="px-3 py-2 border-b border-gray-100">
                  <p className="text-xs font-medium text-gray-900 truncate">{userName}</p>
                  <p className="text-[10px] text-gray-400 capitalize">{userRole}</p>
                </div>
                <button
                  onClick={logout}
                  className="flex items-center gap-2 w-full px-3 py-2 text-xs text-gray-600 hover:bg-gray-50 hover:text-red-500 transition-colors cursor-pointer"
                >
                  <LogOut className="w-3.5 h-3.5" />
                  Sign out
                </button>
              </div>
            )}
          </div>
        </div>

        {/* Mobile Nav */}
        <div className="md:hidden border-t border-gray-100 bg-white px-2 py-1 flex overflow-x-auto gap-0.5 scrollbar-hide">
          {navItems.map((item) => {
            const isActive = location.pathname.startsWith(item.to);
            return (
              <NavLink
                key={item.to}
                to={item.to}
                className={cn(
                  "flex items-center gap-1 px-2.5 py-1.5 rounded-md text-[11px] font-medium whitespace-nowrap transition-colors shrink-0",
                  isActive
                    ? "bg-blue-50 text-blue-700"
                    : "text-gray-500 hover:text-gray-700 hover:bg-gray-100"
                )}
              >
                <item.icon className="w-3 h-3" />
                {item.label}
              </NavLink>
            );
          })}
        </div>
      </header>

      {/* Page Content */}
      <main className="p-4 md:p-6">{children}</main>
    </div>
  );
}
