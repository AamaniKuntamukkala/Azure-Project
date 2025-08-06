import React from 'react';
import { useIsAuthenticated, useMsal } from "@azure/msal-react";
import { loginRequest } from "../authConfig";

const SignInButton = () => {
    const { instance } = useMsal();
    const handleLogin = () => {
        instance.loginRedirect(loginRequest).catch(e => {
            console.error(e);
        });
    }
    return <button onClick={handleLogin}>Sign In</button>;
};

const SignOutButton = () => {
    const { instance } = useMsal();
    const handleLogout = () => {
        instance.logoutRedirect({ postLogoutRedirectUri: "/" });
    }
    return <button onClick={handleLogout}>Sign Out</button>;
};

export const PageLayout = (props) => {
    const isAuthenticated = useIsAuthenticated();

    return (
        <>
            <nav style={{ background: '#2c3e50', color: 'white', padding: '10px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <a href="/" style={{ color: 'white', textDecoration: 'none', fontSize: '20px' }}>Citizen Services Portal</a>
                { isAuthenticated ? <SignOutButton /> : <SignInButton /> }
            </nav>
            <main style={{ padding: '20px' }}>
                {props.children}
            </main>
        </>
    );
};
