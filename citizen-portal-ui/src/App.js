import React from 'react';
import { AuthenticatedTemplate, UnauthenticatedTemplate, useMsal } from '@azure/msal-react';
import { loginRequest } from './authConfig';
import { PageLayout } from './components/PageLayout';
import { ProfileContent } from './components/ProfileContent';

function App() {
    return (
        <PageLayout>
            <AuthenticatedTemplate>
                <ProfileContent />
            </AuthenticatedTemplate>
            <UnauthenticatedTemplate>
                <p>You are not signed in! Please sign in to see your profile information.</p>
            </UnauthenticatedTemplate>
        </PageLayout>
    );
}

export default App;
