import { Refine, Authenticated } from "@refinedev/core";
import routerProvider from "@refinedev/react-router-v6";
import { BrowserRouter, Routes, Route, Navigate, Outlet } from "react-router-dom";
import { pocketbaseDataProvider, pocketbaseAuthProvider } from "@/providers/pocketbase-provider";
import { Layout } from "@/components/layout/Layout";
import { LoginPage } from "@/pages/login";
import { DashboardPage } from "@/pages/dashboard";
import { LeadListPage } from "@/pages/leads/list";
import { UserListPage } from "@/pages/users/list";
import { UserFormPage } from "@/pages/users/show";
import { AttendanceListPage } from "@/pages/attendance/list";
import { CallLogListPage } from "@/pages/call-logs/list";

export default function App() {
  return (
    <BrowserRouter>
      <Refine
        dataProvider={pocketbaseDataProvider}
        authProvider={pocketbaseAuthProvider}
        routerProvider={routerProvider}
        resources={[
          { name: "dashboard", list: "/dashboard" },
          { name: "leads", list: "/leads" },
          { name: "users", list: "/users", show: "/users/:id", edit: "/users/:id" },
          { name: "attendance", list: "/attendance" },
          { name: "call_logs", list: "/call-logs" },
        ]}
      >
        <Routes>
          <Route path="/login" element={<LoginPage />} />

          <Route
            element={
              <Authenticated key="authenticated-routes" fallback={<Navigate to="/login" replace />}>
                <Layout>
                  <Outlet />
                </Layout>
              </Authenticated>
            }
          >
            <Route path="/" element={<Navigate to="/dashboard" replace />} />
            <Route path="/dashboard" element={<DashboardPage />} />
            <Route path="/leads" element={<LeadListPage />} />
            <Route path="/users" element={<UserListPage />} />
            <Route path="/users/:id" element={<UserFormPage />} />
            <Route path="/attendance" element={<AttendanceListPage />} />
            <Route path="/call-logs" element={<CallLogListPage />} />
          </Route>

          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Routes>
      </Refine>
    </BrowserRouter>
  );
}
