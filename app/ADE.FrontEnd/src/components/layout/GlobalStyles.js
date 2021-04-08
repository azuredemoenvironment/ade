import { createGlobalStyle } from 'styled-components';
const GlobalStyles = createGlobalStyle`
	html,
	body {
		font-size: ${(props) => props.theme.fontSize};
        font-family: ${(props) => props.theme.fontBody};
        font-display: swap;
		color: ${(props) => props.theme.grayDark};
	}

	p {
		line-height: 1.5;
		margin: 0 0 1rem 0;
	}

	h1,
	h2,
	h3,
	h4,
	h5,
	h6 {
		font-family: ${(props) => props.theme.fontHeadings};
	}

	a {
		color: ${(props) => props.theme.primary};
		font-weight: bold;
		text-decoration: none;

		&:focus,
		&:hover,
		&:active {
			color: ${(props) => props.theme.secondary};
			text-decoration: underline;
		}
	}

	blockquote {
		font-style: italic;
		color: ${(props) => props.theme.gray};
	}

	.section-heading {
		font-size: 36px;
		font-weight: 700;
		margin-top: 60px;
	}

	.caption {
		font-size: 14px;
		font-style: italic;
		display: block;
		margin: 0;
		padding: 10px;
		text-align: center;
		border-bottom-right-radius: 5px;
		border-bottom-left-radius: 5px;
	}

	::-moz-selection {
		color: ${(props) => props.theme.white};
		background: ${(props) => props.theme.primary};
		text-shadow: none;
	}

	::selection {
		color: ${(props) => props.theme.white};
		background: ${(props) => props.theme.primary};
		text-shadow: none;
	}

	img::selection {
		color: ${(props) => props.theme.white};
		background: transparent;
	}

	img::-moz-selection {
		color: ${(props) => props.theme.white};
		background: transparent;
	}

	.btn {
		font-size: 14px;
		font-weight: 800;
		padding: 15px 25px;
		letter-spacing: 1px;
		text-transform: uppercase;
		border-radius: 0;
	}

	.btn-primary {
		background-color: ${(props) => props.theme.primary};
		border-color: ${(props) => props.theme.primary};
		&:hover,
		&:focus,
		&:active {
			color: ${(props) => props.theme.white};
			background-color: darken(${(props) => props.theme.primary}, 7.5) !important;
			border-color: darken(${(props) => props.theme.primary}, 7.5) !important;
		}
	}

	.btn-lg {
		font-size: 16px;
		padding: 25px 35px;
	}
`;

export default GlobalStyles;
