import {
	useEffect,
	useState
} from 'react';

import Card from 'react-bootstrap/Card';
import CardColumns from 'react-bootstrap/CardColumns';

function UserDataPoints() {
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
			<h2>User Data Points</h2>
			<CardColumns>
				{items.map((item) => (
					<Card style={{ width: '18rem' }} key={item.id}>
						<Card.Header>{item.stringValue}</Card.Header>
						<Card.Body>
							<Card.Title>{item.id}</Card.Title>
							<Card.Subtitle className='mb-2 text-muted'>
								{item.userId}
							</Card.Subtitle>
							<Card.Text>
								<ul>
									<li>{item.integerValue}</li>
									<li>{item.stringValue}</li>
									<li>{item.booleanValue.toString()}</li>
									<li>{item.decimalValue}</li>
									<li>{item.dataSource}</li>
									<li>{item.createdAt}</li>
								</ul>
							</Card.Text>
						</Card.Body>
					</Card>
				))}
			</CardColumns>
		</div>
	);
}

export default UserDataPoints;
