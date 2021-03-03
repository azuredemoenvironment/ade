import Helmet from 'react-helmet';

const CustomHead = () => (
	<Helmet>
		{/* Meta */}
		<meta httpEquiv='Content-Type' content='text/html; charset=utf-8' />
		<meta
			name='viewport'
			content='target-densitydpi=device-dpi, initial-scale=1.0, user-scalable=no'
		/>
		<link
			rel='alternate'
			type='application/rss+xml'
			title='RSS Feed for brandonmartinez.com'
			href='/rss.xml'
		/>

		{/* Styles */}
		<link rel='preconnect' href='https://fonts.gstatic.com' />
		<link
			href='//fonts.googleapis.com/css?family=Source+Sans+Pro:400,600,700,400italic,600italic,700italic'
			rel='stylesheet'
			type='text/css'
			async
		/>
		<link
			href='https://fonts.googleapis.com/css2?family=Work+Sans:wght@300;400;700&display=swap'
			rel='stylesheet'
		/>
		<link
			rel='stylesheet'
			href='https://maxcdn.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css'
			integrity='sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh'
			crossOrigin='anonymous'
		/>

		{/* Site/Page Title */}
		<title>Azure Demo Environment</title>
	</Helmet>
);

export default CustomHead;
