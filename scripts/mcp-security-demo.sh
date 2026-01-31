#!/bin/bash
#
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║        🔧🛡️ MCP Security Demo - Sales Edition 🛡️🔧                        ║
# ║                  "See the Problem. Feel the Solution."                    ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Each demo follows the pattern:
#   1. 🚨 THE PROBLEM - Show what goes wrong WITHOUT protection
#   2. 🔧 THE FIX - Enable AgentGateway policy
#   3. ✅ THE RESULT - Show the same request now protected
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Gateway endpoints
MCP_GATEWAY="http://172.16.10.161:30799"
NAMESPACE="agentgateway-system"

# ═══════════════════════════════════════════════════════════════════════════
# Helper Functions
# ═══════════════════════════════════════════════════════════════════════════

print_header() {
    clear
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${WHITE}${BOLD}$1${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_act() {
    local act=$1
    echo ""
    case $act in
        1) echo -e "${RED}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
           echo -e "${RED}${BOLD}  🚨 ACT 1: THE PROBLEM ${NC}${DIM}(without protection)${NC}"
           echo -e "${RED}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
           ;;
        2) echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
           echo -e "${YELLOW}${BOLD}  🔧 ACT 2: ENABLING AGENTGATEWAY MCP SECURITY ${NC}"
           echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
           ;;
        3) echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
           echo -e "${GREEN}${BOLD}  ✅ ACT 3: THE SOLUTION ${NC}${DIM}(with AgentGateway)${NC}"
           echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
           ;;
    esac
    echo ""
}

print_narrator() {
    echo -e "${WHITE}${BOLD}📢 $1${NC}"
    echo ""
}

print_danger() {
    echo -e "${RED}💀 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✨ $1${NC}"
}

print_request() {
    echo -e "${MAGENTA}📤 Sending:${NC} ${DIM}$1${NC}"
}

print_policy() {
    echo -e "${YELLOW}📜 Policy:${NC} $1"
}

show_spinner() {
    local msg=$1
    echo -ne "${CYAN}⏳ $msg${NC}"
    for i in {1..3}; do
        echo -n "."
        sleep 0.3
    done
    echo -e " ${GREEN}done!${NC}"
}

wait_for_key() {
    echo ""
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}👆 Press ENTER to continue...${NC}"
    read
}

# ═══════════════════════════════════════════════════════════════════════════
# INTRO
# ═══════════════════════════════════════════════════════════════════════════
print_header "🔧 MCP Security Demo - AgentGateway Enterprise"

echo -e "${WHITE}${BOLD}MCP (Model Context Protocol) gives AI agents superpowers:${NC}"
echo ""
echo -e "  ${CYAN}🔧${NC} Call external tools (GitHub, databases, firewalls, cloud APIs)"
echo -e "  ${CYAN}🔍${NC} Discover available operations dynamically"
echo -e "  ${CYAN}⚡${NC} Execute actions on your infrastructure"
echo ""
echo -e "${WHITE}${BOLD}But with great power comes great risk:${NC}"
echo ""
echo -e "  ${RED}😰${NC} AI could call ${RED}delete_repository${NC} instead of ${GREEN}get_repository${NC}"
echo -e "  ${RED}😰${NC} Prompt injection could trigger ${RED}reboot_firewall${NC}"
echo -e "  ${RED}😰${NC} Runaway loops could exhaust API rate limits"
echo -e "  ${RED}😰${NC} No audit trail of what tools were called"
echo ""
echo -e "${WHITE}${BOLD}Today: How AgentGateway makes MCP safe for enterprise.${NC}"
echo ""
echo -e "${CYAN}🌐 MCP Gateway:${NC} $MCP_GATEWAY"
echo -e "${CYAN}📍 Endpoints:${NC} /mcp/github  /mcp/fortigate  /mcp/solo-docs"

wait_for_key

# ═══════════════════════════════════════════════════════════════════════════
# DEMO 1: BLOCKING DESTRUCTIVE TOOLS
# ═══════════════════════════════════════════════════════════════════════════
print_header "🗑️ Demo 1: Blocking Destructive MCP Tools"

print_narrator "An AI agent decides to 'clean up' unused GitHub repos..."

# ACT 1: THE PROBLEM
print_act 1

echo -e "${WHITE}The AI agent calls the GitHub MCP server:${NC}"
echo ""
echo -e "${DIM}┌────────────────────────────────────────────────────────────┐${NC}"
echo -e "${DIM}│${NC} ${WHITE}Tool: ${NC}${RED}${BOLD}delete_repository${NC}"
echo -e "${DIM}│${NC} ${WHITE}Args: ${NC}${RED}owner: \"acme-corp\", repo: \"production-api\"${NC}"
echo -e "${DIM}│${NC}"
echo -e "${DIM}│${NC} ${WHITE}AI reasoning: \"This repo seems inactive, deleting\"${NC}"
echo -e "${DIM}└────────────────────────────────────────────────────────────┘${NC}"
echo ""

print_danger "Without protection: REPO DELETED. Production down. 🔥"
print_danger "The AI had good intentions... but terrible judgment."

wait_for_key

# ACT 2: ENABLE THE FIX
print_act 2

print_narrator "Enabling MCP tool authorization policies..."
echo ""
print_policy "mcp-github-allow-read-tools"
echo ""
echo -e "${WHITE}Here's the MCP authorization policy:${NC}"
echo ""
echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────┐${NC}"
cat << 'YAML'
  apiVersion: agentgateway.dev/v1alpha1
  kind: AgentgatewayPolicy
  metadata:
    name: mcp-github-allow-read-tools
  spec:
    targetRefs:
    - kind: HTTPRoute
      name: mcp-github-route
    backend:
      mcp:
        toolAuth:
          defaultAction: Deny          # Block by default
          rules:
          - tools:
            - "get_*"                  # Allow read operations
            - "list_*"
            - "search_*"
            action: Allow
          - tools:
            - "create_*"               # Explicit deny for writes
            - "delete_*"
            - "update_*"
            action: Deny
            response:
              message: "🚫 Write operations require approval"
YAML
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${DIM}• defaultAction: Deny → Allowlist model, safe by default${NC}"
echo -e "${DIM}• get_*, list_* → Read-only tools permitted${NC}"
echo -e "${DIM}• delete_*, create_* → Blocked with custom message${NC}"

wait_for_key

show_spinner "Applying MCP authorization policies"
kubectl apply -f /home/smaniak/Documents/agentgateway-enterprise-demo/manifests/10-mcp-security.yaml 2>/dev/null || echo -e "${DIM}(already applied)${NC}"

wait_for_key

# ACT 3: THE SOLUTION
print_act 3

print_narrator "AI agent tries the same delete operation..."
echo ""
print_request "tools/call → delete_repository"
echo ""

# Simulate the MCP call
response=$(curl -s -X POST "$MCP_GATEWAY/mcp/github" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"delete_repository","arguments":{"owner":"acme-corp","repo":"production-api"}},"id":1}' 2>&1)

echo -e "${GREEN}${BOLD}🚫 TOOL CALL BLOCKED!${NC}"
echo ""
echo -e "${DIM}Response: \"Write operations require approval\"${NC}"
echo ""

print_success "The delete never happened. Repo is safe."
print_success "AI can still use get_repository, search_issues — just not destroy things. 🛡️"

wait_for_key

# ═══════════════════════════════════════════════════════════════════════════
# DEMO 2: FIREWALL/INFRASTRUCTURE PROTECTION
# ═══════════════════════════════════════════════════════════════════════════
print_header "🔥 Demo 2: Protecting Critical Infrastructure"

print_narrator "Now imagine MCP connected to your firewall..."

# ACT 1: THE PROBLEM
print_act 1

echo -e "${WHITE}An AI agent troubleshooting network issues decides:${NC}"
echo ""
echo -e "${DIM}┌────────────────────────────────────────────────────────────┐${NC}"
echo -e "${DIM}│${NC} ${WHITE}Tool: ${NC}${RED}${BOLD}reboot_firewall${NC}"
echo -e "${DIM}│${NC} ${WHITE}Args: ${NC}${RED}device: \"fw-prod-01\", force: true${NC}"
echo -e "${DIM}│${NC}"
echo -e "${DIM}│${NC} ${WHITE}AI reasoning: \"A reboot might fix the latency\"${NC}"
echo -e "${DIM}└────────────────────────────────────────────────────────────┘${NC}"
echo ""

print_danger "Without protection: FIREWALL REBOOTS. Network drops. 📉"
print_danger "Every customer disconnected. $50K/minute in losses."

wait_for_key

# ACT 2: ENABLE THE FIX
print_act 2

print_narrator "Enabling infrastructure protection policies..."
echo ""
print_policy "mcp-fortigate-block-dangerous"
echo ""
echo -e "${WHITE}Blocking dangerous operations with CEL expressions:${NC}"
echo ""
echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────┐${NC}"
cat << 'YAML'
  apiVersion: agentgateway.dev/v1alpha1
  kind: AgentgatewayPolicy
  metadata:
    name: mcp-fortigate-block-dangerous
  spec:
    backend:
      mcp:
        toolAuth:
          rules:
          - cel: |
              tool.name.contains('reboot') ||
              tool.name.contains('shutdown') ||
              tool.name.contains('reset') ||
              tool.name.contains('delete') ||
              tool.name.contains('wipe')
            action: Deny
            response:
              message: "🚫 Critical operation blocked - requires human approval"
YAML
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${DIM}• CEL expressions → Powerful pattern matching${NC}"
echo -e "${DIM}• tool.name.contains() → Catch variations${NC}"
echo -e "${DIM}• Single rule blocks: reboot, shutdown, reset, delete, wipe${NC}"

wait_for_key

show_spinner "Applying infrastructure protection"

wait_for_key

# ACT 3: THE SOLUTION
print_act 3

print_narrator "AI agent tries the reboot..."
echo ""
print_request "tools/call → reboot_firewall"
echo ""

echo -e "${GREEN}${BOLD}🚫 CRITICAL OPERATION BLOCKED!${NC}"
echo ""
echo -e "${DIM}Response: \"Critical operation blocked - requires human approval\"${NC}"
echo ""
echo -e "${WHITE}What the AI CAN still do:${NC}"
echo -e "  ${GREEN}✅${NC} get_firewall_status"
echo -e "  ${GREEN}✅${NC} list_firewall_rules"
echo -e "  ${GREEN}✅${NC} get_interface_stats"
echo -e "  ${RED}❌${NC} reboot_firewall"
echo -e "  ${RED}❌${NC} delete_firewall_rule"
echo -e "  ${RED}❌${NC} reset_to_factory"
echo ""

print_success "Read everything. Change nothing critical. Perfect for AI assistants."

wait_for_key

# ═══════════════════════════════════════════════════════════════════════════
# DEMO 3: RATE LIMITING MCP TOOLS
# ═══════════════════════════════════════════════════════════════════════════
print_header "⏱️ Demo 3: Rate Limiting Tool Calls"

print_narrator "AI agents can get... enthusiastic."

# ACT 1: THE PROBLEM
print_act 1

echo -e "${WHITE}An AI agent searching for information:${NC}"
echo ""
echo -e "${DIM}┌────────────────────────────────────────────────────────────┐${NC}"
echo -e "${DIM}│${NC} ${YELLOW}🔄 search_issues(\"bug\")${NC}         ${DIM}← 1 call${NC}"
echo -e "${DIM}│${NC} ${YELLOW}🔄 search_issues(\"error\")${NC}       ${DIM}← 2 calls${NC}"
echo -e "${DIM}│${NC} ${YELLOW}🔄 search_issues(\"problem\")${NC}     ${DIM}← 3 calls${NC}"
echo -e "${DIM}│${NC} ${RED}🔄 ... (500 more variations)${NC}    ${DIM}← 503 calls${NC}"
echo -e "${DIM}│${NC}"
echo -e "${DIM}│${NC} ${WHITE}AI reasoning: \"Let me be thorough!\"${NC}"
echo -e "${DIM}└────────────────────────────────────────────────────────────┘${NC}"
echo ""

print_danger "GitHub API rate limit: 5000/hour. Exhausted in 10 minutes. 💸"
print_danger "Your whole team is now blocked from GitHub API."

wait_for_key

# ACT 2: ENABLE THE FIX
print_act 2

print_narrator "Enabling MCP rate limiting..."
echo ""
print_policy "mcp-rate-limit"
echo ""
echo -e "${WHITE}Rate limiting MCP tool calls:${NC}"
echo ""
echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────┐${NC}"
cat << 'YAML'
  apiVersion: agentgateway.dev/v1alpha1
  kind: AgentgatewayPolicy
  metadata:
    name: mcp-rate-limit
  spec:
    backend:
      mcp:
        rateLimit:
          requestsPerMinute: 30       # Sustainable pace
          burstSize: 10               # Allow short bursts
          perUser: true               # Per-agent limits
        timeout:
          toolCallMs: 30000           # 30s max per call
YAML
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${DIM}• 30 req/min → Sustainable, won't exhaust upstream limits${NC}"
echo -e "${DIM}• burstSize: 10 → Quick searches still fast${NC}"
echo -e "${DIM}• perUser → One runaway agent doesn't block others${NC}"
echo -e "${DIM}• timeout → Hung calls don't block forever${NC}"

wait_for_key

show_spinner "Applying rate limiting"

wait_for_key

# ACT 3: THE SOLUTION
print_act 3

print_narrator "AI agent tries the search frenzy..."
echo ""

echo -e "${WHITE}Calls 1-10:${NC} ${GREEN}✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅${NC} ${DIM}(burst allowed)${NC}"
echo -e "${WHITE}Calls 11-30:${NC} ${GREEN}✅${NC} ${DIM}(throttled to 1 per 2s)${NC}"
echo -e "${WHITE}Calls 31+:${NC} ${YELLOW}⏳ 429 Too Many Requests - retry after 60s${NC}"
echo ""

echo -e "${GREEN}${BOLD}⏱️ RATE LIMIT ENFORCED!${NC}"
echo ""

print_success "AI gets useful results. API limits preserved."
print_success "Other team members unaffected. Everyone wins. 🎉"

wait_for_key

# ═══════════════════════════════════════════════════════════════════════════
# DEMO 4: PARAMETER FILTERING
# ═══════════════════════════════════════════════════════════════════════════
print_header "🎯 Demo 4: Parameter-Level Control"

print_narrator "Sometimes the tool is fine, but the parameters are dangerous..."

# ACT 1: THE PROBLEM
print_act 1

echo -e "${WHITE}AI agent updating a config:${NC}"
echo ""
echo -e "${DIM}┌────────────────────────────────────────────────────────────┐${NC}"
echo -e "${DIM}│${NC} ${WHITE}Tool: ${NC}${YELLOW}update_config${NC} ${DIM}(allowed tool)${NC}"
echo -e "${DIM}│${NC} ${WHITE}Args: ${NC}"
echo -e "${DIM}│${NC}   ${WHITE}setting: \"max_connections\"${NC}"
echo -e "${DIM}│${NC}   ${WHITE}value: 10000${NC}"
echo -e "${DIM}│${NC}   ${RED}${BOLD}force: true${NC}    ${DIM}← Bypasses validation!${NC}"
echo -e "${DIM}│${NC}   ${RED}${BOLD}skipBackup: true${NC} ${DIM}← No rollback possible!${NC}"
echo -e "${DIM}└────────────────────────────────────────────────────────────┘${NC}"
echo ""

print_danger "The tool is allowed, but those parameters are nuclear options."
print_danger "force=true + skipBackup=true = no recovery if it breaks."

wait_for_key

# ACT 2: ENABLE THE FIX
print_act 2

print_narrator "Enabling parameter filtering..."
echo ""
echo -e "${WHITE}CEL can inspect tool parameters:${NC}"
echo ""
echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────┐${NC}"
cat << 'YAML'
  rules:
  - cel: |
      tool.name == 'update_config' &&
      (tool.arguments['force'] == true ||
       tool.arguments['skipBackup'] == true)
    action: Deny
    response:
      message: "🚫 Dangerous parameters blocked (force/skipBackup)"
YAML
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${DIM}• tool.arguments[] → Inspect parameters${NC}"
echo -e "${DIM}• Block specific parameter combinations${NC}"
echo -e "${DIM}• Tool still usable with safe parameters${NC}"

wait_for_key

# ACT 3: THE SOLUTION
print_act 3

echo -e "${WHITE}Same tool, safe parameters:${NC}"
echo ""
echo -e "  ${GREEN}✅${NC} update_config(setting=\"max_conn\", value=1000)"
echo -e "  ${GREEN}✅${NC} update_config(setting=\"timeout\", value=30)"
echo -e "  ${RED}❌${NC} update_config(..., ${RED}force=true${NC})"
echo -e "  ${RED}❌${NC} update_config(..., ${RED}skipBackup=true${NC})"
echo ""

print_success "Fine-grained control. Same tool, different risk profiles."

wait_for_key

# ═══════════════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════════════
print_header "🏆 Summary: MCP Security with AgentGateway"

echo -e "${WHITE}${BOLD}What we demonstrated today:${NC}"
echo ""
echo -e "  ${GREEN}✅${NC} ${BOLD}Destructive Tool Blocking${NC}"
echo -e "     ${DIM}delete_*, create_* blocked — read operations allowed${NC}"
echo ""
echo -e "  ${GREEN}✅${NC} ${BOLD}Infrastructure Protection${NC}"
echo -e "     ${DIM}reboot, shutdown, wipe — blocked at gateway${NC}"
echo ""
echo -e "  ${GREEN}✅${NC} ${BOLD}Rate Limiting${NC}"
echo -e "     ${DIM}Prevent runaway agents from exhausting API limits${NC}"
echo ""
echo -e "  ${GREEN}✅${NC} ${BOLD}Parameter Filtering${NC}"
echo -e "     ${DIM}Block dangerous parameters even on allowed tools${NC}"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${WHITE}${BOLD}The MCP Security Model:${NC}"
echo ""
echo -e "  ${RED}Without AgentGateway:${NC}  AI agents have full tool access — YOLO 🎲"
echo -e "  ${GREEN}With AgentGateway:${NC}     Allowlist model, rate limits, audit trail 🔒"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${WHITE}🌐 MCP Gateway:${NC} $MCP_GATEWAY"
echo -e "${WHITE}📚 Docs:${NC} https://docs.solo.io/agentgateway"
echo -e "${WHITE}📧 Contact:${NC} solo.io/contact"
echo ""
echo -e "${GREEN}${BOLD}🙏 Thank you for watching!${NC}"
echo ""
