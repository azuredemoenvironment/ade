import {
	useEffect,
	useState
} from 'react';

import Table from 'react-bootstrap/Table';

function UserDataPoints() {
	const [error, setError] = useState(null);
	const [isLoaded, setIsLoaded] = useState(false);
	const [items, setItems] = useState([]);

	// Note: the empty deps array [] means
	// this useEffect will run once
	// similar to componentDidMount()
	useEffect(() => {
		fetch('http://localhost:5001/datapoints/')
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
			<h2>User Data Points</h2>
			<Table responsive striped bordered hover>
				<thead>
					<tr>
						<td>Id</td>
						<td>Content</td>
						<td>Data Source</td>
						<td>User Id</td>
						<td>Created At</td>
					</tr>
				</thead>
				<tbody>
					{items.map((item) => (
						<tr key={item.id}>
							<td>{item.id}</td>
							<td>{item.content}</td>
							<td>{item.dataSource}</td>
							<td>{item.userId}</td>
							<td>{item.createdAt}</td>
						</tr>
					))}
				</tbody>
			</Table>
		</div>
	);
}

export default UserDataPoints;
