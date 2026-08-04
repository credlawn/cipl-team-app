import { useGetIdentity, useLogout } from "@refinedev/core";
import { LogOut, User, Bell, Search, ShieldCheck } from "lucide-react";
import { Button } from "@/components/ui/button";

export const Header = () => {
  const { data: user } = useGetIdentity<{ name?: string; email?: string; role?: string; avatar?: string }>();
  const { mutate: logout } = useLogout();

  return (
    <header className="sticky top-0 z-30 flex h-16 w-full items-center justify-between border-b border-slate-200 bg-white/80 px-6 backdrop-blur-md">
      <div className="flex items-center gap-4">
        <div className="relative hidden md:block w-72">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            placeholder="Search leads, users, logs..."
            className="w-full rounded-lg border border-slate-200 bg-slate-50 pl-9 pr-4 py-1.5 text-xs text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500 transition-all"
          />
        </div>
      </div>

      <div className="flex items-center gap-3">
        <Button variant="ghost" size="icon" className="relative text-slate-600 hover:text-slate-900">
          <Bell className="h-5 w-5" />
          <span className="absolute top-1.5 right-1.5 h-2 w-2 rounded-full bg-blue-600 ring-2 ring-white" />
        </Button>

        <div className="h-6 w-px bg-slate-200" />

        <div className="flex items-center gap-3 pl-2">
          <div className="flex h-9 w-9 items-center justify-center rounded-full bg-blue-600 text-white font-semibold text-sm shadow-xs">
            {user?.name ? user.name.charAt(0).toUpperCase() : <User className="h-4 w-4" />}
          </div>

          <div className="hidden sm:flex flex-col text-left">
            <span className="text-sm font-semibold text-slate-900 leading-tight">
              {user?.name || "Admin User"}
            </span>
            <span className="text-xs text-slate-500 flex items-center gap-1 font-medium">
              <ShieldCheck className="h-3 w-3 text-blue-600" />
              {user?.role ? user.role.toUpperCase() : "ADMIN"}
            </span>
          </div>

          <Button
            variant="ghost"
            size="icon"
            onClick={() => logout()}
            title="Logout"
            className="text-slate-500 hover:text-red-600 hover:bg-red-50 ml-1 transition-colors"
          >
            <LogOut className="h-4 w-4" />
          </Button>
        </div>
      </div>
    </header>
  );
};
