#!/bin/bash

# Microsoft Dynamics 365 Finance Mock Server Startup Script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/venv"
REQUIREMENTS_FILE="$SCRIPT_DIR/requirements.txt"
SERVER_SCRIPT="$SCRIPT_DIR/mock_server.py"
TEST_SCRIPT="$SCRIPT_DIR/test_server.py"

echo -e "${BLUE}Microsoft Dynamics 365 Finance Mock Server${NC}"
echo -e "${BLUE}===========================================${NC}"

# Function to check if Python 3 is available
check_python() {
    if command -v python3 &> /dev/null; then
        echo -e "${GREEN}✓ Python 3 found${NC}"
        return 0
    elif command -v python &> /dev/null && python --version | grep -q "Python 3"; then
        echo -e "${GREEN}✓ Python 3 found${NC}"
        return 0
    else
        echo -e "${RED}✗ Python 3 not found. Please install Python 3.7 or higher.${NC}"
        return 1
    fi
}

# Function to set up virtual environment
setup_venv() {
    if [ ! -d "$VENV_DIR" ]; then
        echo -e "${YELLOW}Setting up virtual environment...${NC}"
        python3 -m venv "$VENV_DIR"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Virtual environment created${NC}"
        else
            echo -e "${RED}✗ Failed to create virtual environment${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}✓ Virtual environment already exists${NC}"
    fi
    
    # Activate virtual environment
    source "$VENV_DIR/bin/activate"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Virtual environment activated${NC}"
    else
        echo -e "${RED}✗ Failed to activate virtual environment${NC}"
        return 1
    fi
    
    return 0
}

# Function to install dependencies
install_dependencies() {
    echo -e "${YELLOW}Installing dependencies...${NC}"
    pip install --upgrade pip
    pip install -r "$REQUIREMENTS_FILE"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Dependencies installed${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to install dependencies${NC}"
        return 1
    fi
}

# Function to start the server
start_server() {
    echo -e "${YELLOW}Starting mock server...${NC}"
    echo -e "${BLUE}Server will be available at: http://localhost:5000${NC}"
    echo -e "${BLUE}Press Ctrl+C to stop the server${NC}"
    echo ""
    
    python "$SERVER_SCRIPT"
}

# Function to run tests
run_tests() {
    echo -e "${YELLOW}Running tests...${NC}"
    python "$TEST_SCRIPT"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  start     Start the mock server (default)"
    echo "  test      Run the test suite"
    echo "  setup     Set up the environment only"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                # Start the server"
    echo "  $0 start          # Start the server"
    echo "  $0 test           # Run tests"
    echo "  $0 setup          # Set up environment"
}

# Main execution
main() {
    local command="${1:-start}"
    
    case "$command" in
        "help"|"-h"|"--help")
            show_usage
            exit 0
            ;;
        "setup")
            if ! check_python; then
                exit 1
            fi
            if ! setup_venv; then
                exit 1
            fi
            if ! install_dependencies; then
                exit 1
            fi
            echo -e "${GREEN}✓ Setup completed successfully${NC}"
            exit 0
            ;;
        "test")
            if ! check_python; then
                exit 1
            fi
            if ! setup_venv; then
                exit 1
            fi
            if ! install_dependencies; then
                exit 1
            fi
            run_tests
            exit $?
            ;;
        "start")
            if ! check_python; then
                exit 1
            fi
            if ! setup_venv; then
                exit 1
            fi
            if ! install_dependencies; then
                exit 1
            fi
            start_server
            ;;
        *)
            echo -e "${RED}Unknown command: $command${NC}"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
