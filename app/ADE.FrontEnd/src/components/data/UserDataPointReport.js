import {
	useEffect,
	useState
} from 'react';

import Table from 'react-bootstrap/Table';

function UserDataPointReport() {
	const [error, setError] = useState(null);
	const [isLoaded, setIsLoaded] = useState(false);
	const [items, setItems] = useState([]);

	// Note: the empty deps array [] means
	// this useEffect will run once
	// similar to componentDidMount()
	useEffect(() => {
		fetch(process.env.REACT_APP_APIGATEWAYURI + '/datapoints/')
			.then((res) => res.json())
			.then(
				(result) => {
					setIsLoaded(true);
					setItems(result);
				},
				// Note: it's important to handle errors here
				// instead of a catch() block so that we don't swallow
				// exceptions from actual bugs in components.
				(error) => {
					setIsLoaded(true);
					setError(error);
				}
			);
	}, []);

	if (error) {
		return <div>Error: {error.message}</div>;
	} else if (!isLoaded) {
		return <div>Loading...</div>;
	}

	return (
		<div>
			<h2>User Data Point Report</h2>
			<Table>
				<thead>
					<tr>
						<th>Id</th>
						<th>User Id</th>
						<th>String Value</th>
						<th>Integer Value</th>
						<th>Decimal Value</th>
						<th>Boolean Value</th>
						<th>Data Source</th>
						<th>Created At</th>
					</tr>
				</thead>
				<tbody>
					{items.map((item) => (
						<tr key={item.id}>
							<td>{item.id}</td>
							<td>{item.userId}</td>
							<td>{item.stringValue}</td>
							<td>{item.integerValue}</td>
							<td>{item.decimalValue}</td>
							<td>{item.booleanValue.toString()}</td>
							<td>{item.dataSource}</td>
							<td>{item.createdAt}</td>
						</tr>
					))}
				</tbody>
			</Table>
		</div>
	);
}

export default UserDataPointReport;
