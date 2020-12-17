import web3 from './web3';
import CampaignFactory from './build/CampaignFactory.json';

const instance = new web3.eth.Contract(
	JSON.parse(CampaignFactory.interface),
	'0xEE58E7CeDaAA8e03d19D3e81F9106977390775cA'
);

export default instance;
