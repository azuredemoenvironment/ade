import Container from 'react-bootstrap/Container';
import styled from 'styled-components';

// Custom Components
import Footer from './Footer';
import GlobalStyles from './GlobalStyles';
import Head from './Head';
import Header from './Header';

const StyledContainer = styled(({ isScrolled, showHeader, ...rest }) => (
	<Container fluid={false} {...rest} />
))`
	margin-top: ${(props) => (props.showHeader ? 0 : '2rem')};
	padding-left: ${(props) => (props.fluid ? '0' : '1rem')};
	padding-right: ${(props) => (props.fluid ? '0' : '1rem')};
`;

const Layout = ({ children }) => {
	return (
		<>
			<Head />
			<GlobalStyles />
			<Header />

			<StyledContainer>{children}</StyledContainer>

			<Footer />
			<script
				src='https://unpkg.com/react/umd/react.production.min.js'
				crossOrigin='true'
			/>

			<script
				src='https://unpkg.com/react-dom/umd/react-dom.production.min.js'
				crossOrigin='true'
			/>

			<script
				src='https://unpkg.com/react-bootstrap@next/dist/react-bootstrap.min.js'
				crossOrigin='true'
			/>
		</>
	);
};

export default Layout;
