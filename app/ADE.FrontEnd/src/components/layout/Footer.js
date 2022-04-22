import Col from 'react-bootstrap/Col';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import styled from 'styled-components';

// Custom Components
const StyledFooterContainer = styled.footer.attrs((props) => ({
	className: 'pt-4 mt-5'
}))`
	background-color: ${(props) => props.theme.grayDark};
	border-top: 2rem solid ${(props) => props.theme.grayExtraDark};
	color: ${(props) => props.theme.white};

	a {
		color: ${(props) => props.theme.white};
		font-weight: bold;
	}
`;

const Footer = () => (
	<StyledFooterContainer>
		<Container>
			<Row>
				<Col md='4' className='mt-md-0 mt-3'>
					<h5 className='text-uppercase mb-3'>Azure Demo Environment</h5>
				</Col>

				<Col md='4' className='mt-md-0 mt-3'>
					<h5 className='text-uppercase mb-3'>Contribute!</h5>
					<p>Insert contribution pitch and link to GitHub.</p>
				</Col>

				<Col md='4' className='mt-md-0 mt-3'>
					<h5 className='text-uppercase mb-3'>Disclaimer</h5>
					<p>Insert disclaimer.</p>
					<p>Version: {process.env.buildId}</p>
					<p>
						API Endpoint:{' '}
						<a href={window._env_.ADE__APIGATEWAYURI}>
							{window._env_.ADE__APIGATEWAYURI}
						</a>
					</p>
				</Col>
			</Row>
		</Container>
	</StyledFooterContainer>
);

export default Footer;
