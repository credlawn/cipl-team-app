import { DataProvider, AuthProvider } from "@refinedev/core";
import { pb, POCKETBASE_URL } from "@/lib/pocketbase";

export const pocketbaseDataProvider: DataProvider = {
  getList: async ({ resource, pagination, sorters, filters, meta }) => {
    const current = pagination?.current || 1;
    const pageSize = pagination?.pageSize || 50;

    let sort = "";
    if (sorters && sorters.length > 0) {
      sort = sorters
        .map((s) => (s.order === "desc" ? `-${s.field}` : s.field))
        .join(",");
    }

    let filterStr = "";
    if (filters && filters.length > 0) {
      const filterParts: string[] = [];
      filters.forEach((f) => {
        if ("field" in f && f.value !== undefined && f.value !== "") {
          if (f.operator === "eq") {
            if (typeof f.value === "boolean") {
              filterParts.push(`${f.field} = ${f.value}`);
            } else {
              filterParts.push(`${f.field} = "${f.value}"`);
            }
          } else if (f.operator === "contains") {
            filterParts.push(`${f.field} ~ "${f.value}"`);
          } else if (f.operator === "gte") {
            filterParts.push(`${f.field} >= "${f.value}"`);
          } else if (f.operator === "lte") {
            filterParts.push(`${f.field} <= "${f.value}"`);
          } else if (f.operator === "in" && Array.isArray(f.value)) {
            filterParts.push(`(${f.value.map((v) => `${f.field} = "${v}"`).join(" || ")})`);
          }
        }
      });
      filterStr = filterParts.join(" && ");
    }

    const options: Record<string, any> = {};
    if (sort) options.sort = sort;
    if (filterStr) options.filter = filterStr;
    if (meta?.expand) options.expand = meta.expand;

    try {
      const result = await pb.collection(resource).getList(current, pageSize, options);
      return {
        data: result.items as any[],
        total: result.totalItems,
      };
    } catch (error) {
      console.warn(`[PocketBase Query Error] resource="${resource}" filter="${filterStr}":`, error);
      return { data: [], total: 0 };
    }
  },

  getOne: async ({ resource, id, meta }) => {
    const options: Record<string, any> = {};
    if (meta?.expand) options.expand = meta.expand;

    const record = await pb.collection(resource).getOne(id as string, options);
    return { data: record as any };
  },

  create: async ({ resource, variables }) => {
    const record = await pb.collection(resource).create(variables as Record<string, any>);
    return { data: record as any };
  },

  update: async ({ resource, id, variables }) => {
    const record = await pb.collection(resource).update(id as string, variables as Record<string, any>);
    return { data: record as any };
  },

  deleteOne: async ({ resource, id }) => {
    const record = await pb.collection(resource).delete(id as string);
    return { data: record as any };
  },

  getApiUrl: () => POCKETBASE_URL,
};

export const pocketbaseAuthProvider: AuthProvider = {
  login: async ({ email, password }) => {
    try {
      const authData = await pb.collection("users").authWithPassword(email, password);
      if (authData.token) {
        return {
          success: true,
          redirectTo: "/dashboard",
        };
      }
    } catch (error: any) {
      return {
        success: false,
        error: {
          name: "LoginError",
          message: error?.message || "Invalid credentials or unauthorized login.",
        },
      };
    }
    return {
      success: false,
      error: {
        name: "LoginError",
        message: "Failed to authenticate.",
      },
    };
  },

  logout: async () => {
    pb.authStore.clear();
    return {
      success: true,
      redirectTo: "/login",
    };
  },

  check: async () => {
    if (pb.authStore.isValid) {
      return { authenticated: true };
    }
    return {
      authenticated: false,
      redirectTo: "/login",
    };
  },

  onError: async (error) => {
    if (error?.status === 401) {
      return { logout: true };
    }
    return { error };
  },

  getPermissions: async () => {
    return pb.authStore.record?.role || "user";
  },

  getIdentity: async () => {
    if (!pb.authStore.isValid || !pb.authStore.record) {
      return null;
    }
    const user = pb.authStore.record;
    return {
      id: user.id,
      name: user.name || user.email,
      email: user.email,
      avatar: user.avatar ? pb.files.getUrl(user, user.avatar) : undefined,
      role: user.role,
      branch: user.branch_name,
    };
  },
};
