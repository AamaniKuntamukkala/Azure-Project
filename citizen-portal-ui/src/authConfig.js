// MSAL configuration
export const msalConfig = {
    auth: {
        clientId: "bae912ef-bd7d-41f3-be2e-bc6bd294c2e2", // Client ID of the "CitizenPortal-UI" App Registration in Azure AD
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
    scopes: ["api://74a22459-53e6-4b4a-97b2-4a0bb7100daf/api.access"] 
    // scopes: ["api://YOUR_BACKEND_API_CLIENT_ID/api.access"] // We will configure this later
};
