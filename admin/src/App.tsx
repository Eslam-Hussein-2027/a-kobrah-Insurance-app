import { BrowserRouter, Navigate, Route, Routes } from 'react-router';
import { Layout, RequireAuth } from './components/Layout';
import { CustomerDetailsPage } from './pages/CustomerDetailsPage';
import { CustomersPage } from './pages/CustomersPage';
import { LoginPage } from './pages/LoginPage';
import { OverviewPage } from './pages/OverviewPage';
import { PaymentsPage } from './pages/PaymentsPage';
import { PoliciesPage } from './pages/PoliciesPage';
import { PolicyDetailsPage } from './pages/PolicyDetailsPage';
import { PricingPage } from './pages/PricingPage';

export function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route
          element={
            <RequireAuth>
              <Layout />
            </RequireAuth>
          }
        >
          <Route index element={<OverviewPage />} />
          <Route path="policies" element={<PoliciesPage />} />
          <Route path="policies/:id" element={<PolicyDetailsPage />} />
          <Route path="payments" element={<PaymentsPage />} />
          <Route path="customers" element={<CustomersPage />} />
          <Route path="customers/:id" element={<CustomerDetailsPage />} />
          <Route path="pricing" element={<PricingPage />} />
        </Route>
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
