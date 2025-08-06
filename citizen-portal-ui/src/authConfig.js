// MSAL configuration
export const msalConfig = {
    auth: {
        clientId: "YOUR_FRONTEND_APP_CLIENT_ID", // Client ID of the "App Registration" in Azure AD
        authority: "https://login.microsoftonline.com/YOUR_TENANT_ID", // Tenant ID of your Azure AD
        redirectUri: "http://localhost:3000" // Must match the redirect URI in your App Registration
    },
    cache: {
        cacheLocation: "sessionStorage", 
        storeAuthStateInCookie: false, 
    }
};

// Scopes you want to request for the access token
export const loginRequest = {
    scopes: ["api://YOUR_BACKEND_API_CLIENT_ID/api.access"]
};
