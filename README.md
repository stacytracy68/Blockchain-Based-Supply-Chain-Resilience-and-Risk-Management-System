# Blockchain-Based Supply Chain Resilience and Risk Management System

## Overview

This system provides a comprehensive blockchain-based solution for supply chain resilience and risk management. It consists of five interconnected smart contracts that work together to ensure supply chain continuity, optimize operations, and mitigate risks in global supply networks.

## System Architecture

### Core Contracts

1. **Supply Chain Vulnerability Assessment Contract** (`supply-chain-vulnerability.clar`)
    - Identifies and assesses risks in global supply networks
    - Tracks vulnerability scores and risk factors
    - Provides early warning systems for potential disruptions

2. **Alternative Supplier Coordination Contract** (`alternative-supplier-coordination.clar`)
    - Maintains a network of backup suppliers
    - Coordinates supplier switching during crises
    - Manages supplier capacity and availability

3. **Inventory Optimization Contract** (`inventory-optimization.clar`)
    - Balances stock levels to minimize costs
    - Ensures product availability during disruptions
    - Implements dynamic reorder point calculations

4. **Logistics Route Optimization Contract** (`logistics-route-optimization.clar`)
    - Dynamically adjusts shipping routes based on real-time conditions
    - Optimizes for cost, time, and risk factors
    - Manages route disruptions and alternatives

5. **Supplier Performance Monitoring Contract** (`supplier-performance-monitoring.clar`)
    - Tracks quality, delivery, and sustainability metrics
    - Maintains supplier scorecards and ratings
    - Implements performance-based supplier selection

## Key Features

### Risk Management
- Real-time vulnerability assessment
- Automated risk scoring and alerts
- Historical risk pattern analysis
- Predictive risk modeling

### Supplier Management
- Multi-tier supplier network management
- Automated backup supplier activation
- Performance-based supplier ranking
- Sustainability and compliance tracking

### Inventory Optimization
- Dynamic safety stock calculations
- Demand forecasting integration
- Cost-optimized reorder strategies
- Multi-location inventory balancing

### Logistics Optimization
- Real-time route optimization
- Disruption-aware routing
- Cost and time optimization
- Environmental impact consideration

## Data Structures

### Supplier Information
- Supplier ID and basic information
- Capacity and capability metrics
- Performance history and ratings
- Risk assessment scores

### Inventory Management
- Product information and classifications
- Stock levels across locations
- Reorder points and safety stock
- Demand forecasting data

### Risk Assessment
- Vulnerability categories and scores
- Geographic and political risk factors
- Supply chain dependency mapping
- Historical disruption data

## Smart Contract Functions

### Administrative Functions
- Contract initialization and configuration
- User role management
- System parameter updates
- Emergency controls

### Operational Functions
- Risk assessment and monitoring
- Supplier coordination and switching
- Inventory level management
- Route optimization and updates

### Query Functions
- Risk status retrieval
- Supplier information lookup
- Inventory level checking
- Performance metrics access

## Security Features

- Role-based access control
- Input validation and sanitization
- Emergency pause mechanisms
- Audit trail maintenance

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm for testing
- Basic understanding of Clarity smart contracts

### Installation

1. Clone the repository
2. Install dependencies: \`npm install\`
3. Run tests: \`npm test\`
4. Deploy contracts: \`clarinet deploy\`

### Configuration

1. Initialize contracts with system parameters
2. Set up user roles and permissions
3. Configure risk thresholds and alerts
4. Import initial supplier and inventory data

## Testing

The system includes comprehensive tests using Vitest:
- Unit tests for each contract function
- Integration tests for cross-contract workflows
- Performance and stress testing
- Security and edge case testing

Run tests with:
\`\`\`bash
npm test
\`\`\`

## Usage Examples

### Assessing Supply Chain Vulnerability
\`\`\`clarity
(contract-call? .supply-chain-vulnerability assess-vulnerability supplier-id risk-factors)
\`\`\`

### Activating Alternative Supplier
\`\`\`clarity
(contract-call? .alternative-supplier-coordination activate-backup-supplier primary-supplier-id product-id)
\`\`\`

### Optimizing Inventory Levels
\`\`\`clarity
(contract-call? .inventory-optimization calculate-reorder-point product-id location-id)
\`\`\`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For questions and support, please open an issue in the repository.
