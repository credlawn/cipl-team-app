import { useState, useEffect, useCallback } from "react";
import { pb } from "@/lib/pocketbase";

export function useAuth() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);
  const [user, setUser] = useState<Record<string, unknown> | null>(null);

  useEffect(() => {
    const checkAuth = () => {
      if (pb.authStore.isValid) {
        const model = pb.authStore.record;
        const role = (model?.role as string || "").toLowerCase();
        const hasBHAccess = Boolean(model?.bh_access);
        if (hasBHAccess || role === "bh" || role === "manager") {
          setIsAuthenticated(true);
          setUser(model as unknown as Record<string, unknown>);
        } else {
          pb.authStore.clear();
          setIsAuthenticated(false);
          setUser(null);
        }
      } else {
        setIsAuthenticated(false);
        setUser(null);
      }
      setLoading(false);
    };

    checkAuth();

    const unsubscribe = pb.authStore.onChange(() => {
      checkAuth();
    });

    return () => {
      unsubscribe();
    };
  }, []);

  const login = useCallback(
    async (email: string, password: string) => {
      const authData = await pb
        .collection("users")
        .authWithPassword(email, password);

      const role = (authData.record.role || "").toLowerCase();
      const hasBHAccess = Boolean(authData.record.bh_access);
      if (!hasBHAccess && role !== "bh" && role !== "manager") {
        pb.authStore.clear();
        throw new Error("ACCESS_DENIED");
      }

      setIsAuthenticated(true);
      setUser(authData.record as unknown as Record<string, unknown>);
      return authData;
    },
    []
  );

  const logout = useCallback(() => {
    pb.authStore.clear();
    setIsAuthenticated(false);
    setUser(null);
  }, []);

  return { isAuthenticated, loading, user, login, logout };
}
