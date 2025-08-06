import React, { useState } from 'react';
import { useMsal } from "@azure/msal-react";
import { loginRequest } from "../authConfig";

// **REPLACE WITH THE URL OF YOUR DEPLOYED AZURE FUNCTION**
const functionApiEndpoint = "YOUR_FUNCTION_APP_URL/api/GetCitizenData";

export const ProfileContent = () => {
    const { instance, accounts } = useMsal();
    const [apiData, setApiData] = useState(null);

    const name = accounts[0] && accounts[0].name;

    function RequestApiData() {
        const request = {
            ...loginRequest,
            account: accounts[0]
        };

        // Silently acquire the token
        instance.acquireTokenSilent(request).then((response) => {
            const headers = new Headers();
            const bearer = `Bearer ${response.accessToken}`;
            headers.append("Authorization", bearer);

            fetch(functionApiEndpoint, { 
                method: "GET",
                headers: headers
            })
            .then(response => response.text()) // Use .text() as the function returns a simple string
            .then(data => setApiData(data))
            .catch(error => console.log(error));

        }).catch((e) => {
            // Fallback to interactive token acquisition if silent fails
            instance.acquireTokenRedirect(request).catch(e => {
                console.error(e);
            });
        });
    }

    return (
        <>
            <h5 style={{ marginTop: 0 }}>Welcome, {name}</h5>
            {apiData ? 
                <p><strong>Response from API:</strong> {apiData}</p> 
                : 
                <button onClick={RequestApiData}>Call Backend API</button>
            }
        </>
    );
};
