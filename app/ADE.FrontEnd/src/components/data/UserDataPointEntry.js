import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';

function UserDataPointReport() {
	return (
		<Form className='mb-3'>
			<h2>Enter New Data Point</h2>

			<Form.Group controlId='formStringValue'>
				<Form.Label>String Value</Form.Label>
				<Form.Control type='text' placeholder='Enter Value' />
			</Form.Group>

			<Form.Group controlId='formIntegerValue'>
				<Form.Label>Integer Value</Form.Label>
				<Form.Control type='text' placeholder='Enter Value' />
			</Form.Group>

			<Form.Group controlId='formDecimalValue'>
				<Form.Label>Decimal Value</Form.Label>
				<Form.Control type='text' placeholder='Enter Value' />
			</Form.Group>

			<Form.Group controlId='formBooleanValue'>
				<Form.Label>Boolean Value</Form.Label>
				<Form.Control type='text' placeholder='Enter Value' />
			</Form.Group>

			<Button variant='primary' type='submit'>
				Submit
			</Button>
		</Form>
	);
}

export default UserDataPointReport;
