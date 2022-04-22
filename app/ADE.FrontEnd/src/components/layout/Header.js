import { useState } from 'react';

import Container from 'react-bootstrap/Container';
import Nav from 'react-bootstrap/Nav';
import Navbar from 'react-bootstrap/Navbar';
import styled from 'styled-components';

import { useScrollPosition } from '@n8tb1t/use-scroll-position';

const StyledNavbarWrapper = ({ isScrolled, ...rest }) => (
	<Navbar expand='lg' fixed='top' variant='dark' {...rest} />
);
const StyledNavbar = styled(StyledNavbarWrapper)`
	background-color: ${(props) => props.theme.siteNavigationBackgroundColor};
	border-bottom: ${(props) => props.theme.borderWidth} solid
		${(props) => props.theme.grayLight};
	color: ${(props) => props.theme.white};
	transition: all 1s ease-out 0s;
	opacity: ${(props) => (props.isScrolled ? 0.8 : 1)};

	&:hover {
		opacity: 1;
	}

	.navbar-brand {
		font-size: 1.5rem;
		font-family: ${(props) => props.theme.fontHeadings};
		letter-spacing: 0.2rem;
		font-weight: 800;
		color: ${(props) => props.theme.white};

		@media only screen and (min-width: ${(props) =>
				props.theme.breakpointLarge}) {
			padding: 10px 20px;
			color: ${(props) => props.theme.white};
			&:focus,
			&:hover {
				color: fade-out(${(props) => props.theme.white}, 0.2);
			}
		}
	}

	.navbar-toggler {
		font-size: 1rem;
		font-weight: 800;
		padding: 13px;
		text-transform: uppercase;
		color: ${(props) => props.theme.white};
	}

	@media only screen and (min-width: ${(props) =>
			props.theme.breakpointLarge}) {
		border-bottom: 1px solid transparent;
	}
`;

const NavLink = ({ className, children, ...rest }) => (
	<Nav.Item className={className}>
		<Nav.Link {...rest}>{children}</Nav.Link>
	</Nav.Item>
);

const StyledNavbarLink = styled(NavLink)`
	font-size: 1rem;
	font-weight: 800;
	letter-spacing: 1px;
	text-transform: uppercase;

	@media only screen and (min-width: ${(props) =>
			props.theme.breakpointLarge}) {
		padding: 10px 20px;
		color: ${(props) => props.theme.white};
		&:focus,
		&:hover {
			color: fade-out(${(props) => props.theme.white}, 0.2);
		}
	}
`;

const StyledHeroBanner = styled.div`
	background-image: url('./banner.png');
	background-size: cover;
	background-position: center center;
	background-repeat: no-repeat;
	height: 400px;
	width: 100%;
`;

const Header = () => {
	const [isScrolled, setIsScrolled] = useState(false);

	useScrollPosition(
		({ prevPos, currPos }) => {
			const nbc = Math.abs(currPos.y) > 100;
			setIsScrolled(nbc);
		},
		[isScrolled],
		null,
		true,
		600
	);

	return (
		<div>
			<StyledNavbar isScrolled={isScrolled}>
				<Container>
					<Navbar.Brand href='/'>Azure Demo Environment</Navbar.Brand>
					<Navbar.Toggle
						aria-controls='navbar-toggler'
						aria-expanded='false'
						area-label='Toggle Navigation'
					/>
					{/* <Navbar.Collapse id='navbar-toggler'>
						<Nav className='ml-auto'>
							<StyledNavbarLink href='/'>Home</StyledNavbarLink>
						</Nav>
					</Navbar.Collapse> */}
				</Container>
			</StyledNavbar>
			<StyledHeroBanner />
		</div>
	);
};

export default Header;
