import { useState } from 'react';

import Button from 'react-bootstrap/Button';
import Col from 'react-bootstrap/Col';
import Container from 'react-bootstrap/Container';
import Form from 'react-bootstrap/Form';
import Row from 'react-bootstrap/Row';

function UserDataPointReport() {
	const [dataPoint, setDataPoint] = useState({});

	const submit = (e) => {
		e.preventDefault();

		const body = JSON.stringify(dataPoint);
		console.log(body);

		fetch(process.env.REACT_APP_APIGATEWAYURI + '/datapoints/', {
			method: 'POST',
			body,
			headers: { 'Content-Type': 'application/json' }
		}).then((res) => setDataPoint({}));
	};

	return (
		<Form className='mb-3' onSubmit={submit}>
			<Container>
				<Row>
					<Col>
						<h2>Enter New Data Point</h2>
					</Col>
				</Row>
				<Row>
					<Col>
						<Form.Group controlId='formStringValue'>
							<Form.Label>String Value</Form.Label>
							<Form.Control
								type='text'
								placeholder='Enter Value'
								value={dataPoint.stringValue}
								onChange={(e) =>
									setDataPoint({ ...dataPoint, stringValue: e.target.value })
								}
							/>
						</Form.Group>

						<Form.Group controlId='formIntegerValue'>
							<Form.Label>Integer Value</Form.Label>
							<Form.Control
								type='text'
								placeholder='Enter Value'
								value={dataPoint.integerValue}
								onChange={(e) =>
									setDataPoint({
										...dataPoint,
										integerValue: parseInt(e.target.value, 10)
									})
								}
							/>
						</Form.Group>
					</Col>
					<Col>
						<Form.Group controlId='formDecimalValue'>
							<Form.Label>Decimal Value</Form.Label>
							<Form.Control
								type='text'
								placeholder='Enter Value'
								value={dataPoint.decimalValue}
								onChange={(e) =>
									setDataPoint({
										...dataPoint,
										decimalValue: parseFloat(e.target.value)
									})
								}
							/>
						</Form.Group>

						{/* <Form.Group controlId='formBooleanValue'>
				<Form.Label>Boolean Value</Form.Label>
				<Form.Control
					type='text'
					placeholder='Enter Value'
					value={dataPoint.booleanValue}
					onChange={(e) =>
						setDataPoint({
							...dataPoint,
							booleanValue: e.target.value.toLowerCase() === 'true'
						})
					}
				/>
			</Form.Group> */}

						<Button variant='primary' type='submit'>
							Submit
						</Button>
					</Col>
				</Row>
			</Container>
		</Form>
	);
}

export default UserDataPointReport;
