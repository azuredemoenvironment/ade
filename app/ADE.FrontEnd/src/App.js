import './App.css';

import { ThemeProvider } from 'styled-components';

import UserDataPointEntry from './components/data/UserDataPointEntry';
import UserDataPointReport from './components/data/UserDataPointReport';
import Layout from './components/layout/Layout';
import ThemeProviderTheme from './components/layout/ThemeProviderTheme';

function App() {
	return (
		<ThemeProvider theme={ThemeProviderTheme}>
			<Layout>
				<h1>Welcome!</h1>
				<p>
					The Azure Demo Environment, aka ADE, is a series of PowerShell
					Scripts, CLI Script, and ARM Templates that automatically generates an
					environment of Azure Resources and Services to an Azure Subscription.
					While not every Azure Service is deployed as a part of ADE, it does
					showcase many of the common, and more often complex, scenarios withing
					Azure, and it can be used as an example when designing a solution. The
					Azure Demo Environment is built to be deployed, deallocated,
					allocated, removed and re-deployed. The deployment and removal
					processes take approximate two hours. Instructions are provided below.
					The Azure Demo Environment is an Open Source Project. Contributions
					are welcome and encouraged!
				</p>
				<UserDataPointEntry />
				<UserDataPointReport />
			</Layout>
		</ThemeProvider>
	);
}

export default App;
