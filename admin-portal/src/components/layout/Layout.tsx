import React from "react";
import { Header } from "./Header";
import { Sidebar } from "./Sidebar";

export const Layout: React.FC<{ children?: React.ReactNode }> = ({ children }) => {
  return (
    <div className="flex min-h-screen bg-slate-50 font-sans text-slate-900 antialiased">
      <Sidebar />
      <div className="flex flex-1 flex-col overflow-x-hidden w-full">
        <Header />
        <main className="flex-1 p-6 md:p-8 w-full">{children}</main>
      </div>
    </div>
  );
};
