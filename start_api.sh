#!/bin/bash
# Start Jcamp Python API Server (Phase 8+)
# This script ensures the API runs from the correct working directory

echo "======================================"
echo "  JCAMP FOREX BACKTESTING API"
echo "======================================"
echo ""

# Kill any existing instances
echo "[1/3] Checking for existing API servers..."
if pgrep -f "uvicorn.*src.api.main" > /dev/null; then
    echo "⚠️  Found existing API server, killing it..."
    pkill -f "uvicorn.*src.api.main"
    sleep 2
    echo "✅ Old server stopped"
else
    echo "ℹ️  No existing server found"
fi

# Change to correct directory
echo ""
echo "[2/3] Changing to Python backend directory..."
cd /d/Jcamp_TradingApp/jcamp-python-backtesting

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Could not change to jcamp-python-backtesting directory!"
    echo "   Make sure you're running from D:/Jcamp_TradingApp/"
    exit 1
fi

echo "✅ Working directory: $(pwd)"

# Verify data directory exists
echo ""
echo "[3/3] Verifying data directory..."
if [ -d "data/EURUSD.sml" ]; then
    echo "✅ Data directory found"
    echo "   EURUSD files: $(ls data/EURUSD.sml/*.csv | wc -l)"
    echo "   GBPUSD files: $(ls data/GBPUSD.sml/*.csv 2>/dev/null | wc -l)"
else
    echo "❌ ERROR: data/EURUSD.sml not found!"
    echo "   Current directory: $(pwd)"
    exit 1
fi

# Start API server
echo ""
echo "======================================"
echo "  STARTING API SERVER"
echo "======================================"
echo ""
echo "📡 Starting on http://localhost:8000"
echo "📋 API docs: http://localhost:8000/docs"
echo ""
echo "✅ Ready to accept backtest requests!"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

python -m uvicorn src.api.main:app --reload --port 8000
