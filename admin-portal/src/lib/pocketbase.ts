import PocketBase from "pocketbase";

// Use relative window.location.origin so Vite dev proxy handles mode switching:
// mode="server"   -> Proxies /api to https://app.cipl.me
// mode="devlocal" -> Proxies /api to http://localhost:8090
const getBaseUrl = () => {
  if (typeof window !== "undefined") {
    return window.location.origin;
  }
  return "http://127.0.0.1:8090";
};

export const pb = new PocketBase(getBaseUrl());
export const POCKETBASE_URL = getBaseUrl();
