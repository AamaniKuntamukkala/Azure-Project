// MSAL configuration
export const msalConfig = {
    auth: {
        clientId: "8f34b583-6928-458e-a50f-116a2d1b3b2d", // Client ID of the "App Registration" in Azure AD
        authority: "https://login.microsoftonline.com/30fe8ff1-adc6-444d-ba94-1238894df42c", // Tenant ID of your Azure AD

    },
    cache: {
        cacheLocation: "sessionStorage", 
        storeAuthStateInCookie: false, 
    }
};

// Scopes you want to request for the access token
export const loginRequest = {
    // Temporarily use a default scope to test sign-in
    scopes: ["User.Read"] 
    // scopes: ["api://YOUR_BACKEND_API_CLIENT_ID/api.access"] // We will configure this later
};
