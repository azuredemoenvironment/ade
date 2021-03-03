const theme = {
	// Colors
	black: '#000',
	blue: '#007bff',
	cyan: '#17a2b8',
	gray: '#aaa',
	grayDark: '#36383c',
	grayExtraDark: '#222',
	grayLight: '#ececec',
	green: '#28a745',
	indigo: '#6610f2',
	orange: '#fd7e14',
	pink: '#e83e8c',
	purple: '#6f42c1',
	red: '#dc3545',
	teal: '#0085a1',
	white: '#fff',
	yellow: '#ffc107',
	// Fonts
	fontSize: '18px',
	fontHeadings: "'Work Sans', helvetica, arial, sans-serif",
	fontBody: "'Source Sans Pro', helvetica, arial, sans-serif",
	// Media Query BreakPoints
	breakpointSmall: '576px',
	breakpointMedium: '768px',
	breakpointLarge: '992px',
	breakpointExtraLarge: '1200px',
	// Gutters
	gutterSmall: '0.5rem',
	gutter: '1rem',
	gutterLarge: '2rem',
	gutterExtraLarge: '3.5rem',
	// Borders
	borderWidthSmall: '0.05rem',
	borderWidth: '0.1rem',
	borderWidthLarge: '0.2rem',
	borderRadiusSmall: '0.25rem',
	borderRadius: '0.6rem',
	borderRadiusLarge: '1.2rem',
	// Filters
	blurRadius: '0.2rem',
	textShadow: '0.1rem 0.1rem 0.3rem #000',
	boxShadowLight: '0 0.05rem 0.3rem rgba(0, 0, 0, 0.25)',
	boxShadow: '0 0.05rem 0.3rem rgba(0, 0, 0, 0.5)',
	boxShadowDark: '0 0.05rem 0.3rem rgba(0, 0, 0, 0.75)'
};

// Combined Theme Styles
theme.border = `solid ${theme.borderWidth} ${theme.gray}`;
theme.borderLight = `solid ${theme.borderWidth} ${theme.grayLight}`;

// Theme Helpers
theme.danger = theme.red;
theme.dark = theme.grayDark;
theme.info = theme.cyan;
theme.light = theme.grayLight;
theme.primary = theme.teal;
theme.secondary = theme.gray;
theme.success = theme.green;
theme.warning = theme.yellow;

export default theme;
