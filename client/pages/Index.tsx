import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { 
  TrendingUp, 
  TrendingDown, 
  DollarSign, 
  FileText, 
  Calculator, 
  Users, 
  Building2, 
  Calendar,
  Receipt,
  PieChart,
  BarChart3,
  AlertCircle,
  CheckCircle,
  Clock,
  Settings,
  Plus,
  Bell,
  Search,
  Filter,
  Download,
  Eye
} from "lucide-react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

interface DashboardMetrics {
  totalRevenue: number;
  vatOwed: number;
  outstandingReceivables: number;
  payablesDue: number;
  monthlyGrowth: number;
  activeClients: number;
  pendingInvoices: number;
  overdueInvoices: number;
}

interface RecentTransaction {
  id: string;
  type: "invoice" | "payment" | "expense";
  description: string;
  amount: number;
  currency: string;
  date: string;
  status: "pending" | "completed" | "overdue";
  vatAmount?: number;
  whtAmount?: number;
}

interface TaxAlert {
  id: string;
  type: "vat_due" | "paye_due" | "wht_due" | "filing_deadline";
  title: string;
  description: string;
  dueDate: string;
  priority: "high" | "medium" | "low";
}

export default function Index() {
  const [metrics, setMetrics] = useState<DashboardMetrics>({
    totalRevenue: 485250000, // RWF
    vatOwed: 87345000,
    outstandingReceivables: 125000000,
    payablesDue: 65000000,
    monthlyGrowth: 12.5,
    activeClients: 147,
    pendingInvoices: 23,
    overdueInvoices: 8
  });

  const [recentTransactions] = useState<RecentTransaction[]>([
    {
      id: "INV-2024-001",
      type: "invoice",
      description: "Professional Services - Kigali Tech Solutions Ltd",
      amount: 15000000,
      currency: "RWF",
      date: "2024-01-15",
      status: "completed",
      vatAmount: 2700000,
      whtAmount: 2250000
    },
    {
      id: "PAY-2024-045",
      type: "payment",
      description: "Office Rent - January 2024",
      amount: 2500000,
      currency: "RWF",
      date: "2024-01-14",
      status: "completed"
    },
    {
      id: "INV-2024-002",
      type: "invoice",
      description: "Software Development - Rwanda Bank Ltd",
      amount: 25000000,
      currency: "RWF",
      date: "2024-01-13",
      status: "pending",
      vatAmount: 4500000
    },
    {
      id: "EXP-2024-021",
      type: "expense",
      description: "Equipment Purchase - Dell Computers",
      amount: 8500000,
      currency: "RWF",
      date: "2024-01-12",
      status: "overdue"
    }
  ]);

  const [taxAlerts] = useState<TaxAlert[]>([
    {
      id: "alert-1",
      type: "vat_due",
      title: "VAT Return Due",
      description: "Monthly VAT return filing deadline approaching for December 2023",
      dueDate: "2024-01-15",
      priority: "high"
    },
    {
      id: "alert-2",
      type: "paye_due",
      title: "PAYE Filing Due",
      description: "Employee PAYE returns must be submitted",
      dueDate: "2024-01-20",
      priority: "medium"
    },
    {
      id: "alert-3",
      type: "wht_due",
      title: "Withholding Tax Certificates",
      description: "Issue WHT certificates to suppliers for Q4 2023",
      dueDate: "2024-01-31",
      priority: "medium"
    }
  ]);

  const formatRWF = (amount: number) => {
    return new Intl.NumberFormat('en-RW', {
      style: 'currency',
      currency: 'RWF',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(amount);
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case "completed": return "bg-success text-success-foreground";
      case "pending": return "bg-warning text-warning-foreground";
      case "overdue": return "bg-destructive text-destructive-foreground";
      default: return "bg-muted text-muted-foreground";
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case "high": return "bg-destructive text-destructive-foreground";
      case "medium": return "bg-warning text-warning-foreground";
      case "low": return "bg-info text-info-foreground";
      default: return "bg-muted text-muted-foreground";
    }
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="flex h-16 items-center justify-between">
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <Building2 className="h-8 w-8 text-primary" />
                <div>
                  <h1 className="text-xl font-bold text-foreground">Rwanda AMS</h1>
                  <p className="text-xs text-muted-foreground">Accounting Management System</p>
                </div>
              </div>
            </div>
            
            <div className="flex items-center space-x-4">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  type="text"
                  placeholder="Search transactions, invoices..."
                  className="w-64 pl-10"
                />
              </div>
              <Button variant="outline" size="sm">
                <Bell className="h-4 w-4" />
              </Button>
              <Button variant="outline" size="sm">
                <Settings className="h-4 w-4" />
              </Button>
            </div>
          </div>
        </div>
      </header>

      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-8">
        {/* Page Title and Actions */}
        <div className="mb-8 flex items-center justify-between">
          <div>
            <h2 className="text-3xl font-bold tracking-tight text-foreground">Dashboard</h2>
            <p className="text-muted-foreground">
              Monitor your business finances and Rwanda tax compliance
            </p>
          </div>
          <div className="flex items-center space-x-3">
            <Button variant="outline">
              <Download className="mr-2 h-4 w-4" />
              Export Reports
            </Button>
            <Button>
              <Plus className="mr-2 h-4 w-4" />
              New Invoice
            </Button>
          </div>
        </div>

        {/* Metrics Grid */}
        <div className="mb-8 grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Total Revenue</CardTitle>
              <DollarSign className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{formatRWF(metrics.totalRevenue)}</div>
              <p className="text-xs text-muted-foreground">
                +{metrics.monthlyGrowth}% from last month
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">VAT Owed</CardTitle>
              <Calculator className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{formatRWF(metrics.vatOwed)}</div>
              <p className="text-xs text-muted-foreground">
                Due: January 15, 2024
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Outstanding A/R</CardTitle>
              <TrendingUp className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{formatRWF(metrics.outstandingReceivables)}</div>
              <p className="text-xs text-muted-foreground">
                {metrics.pendingInvoices} pending invoices
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Payables Due</CardTitle>
              <TrendingDown className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{formatRWF(metrics.payablesDue)}</div>
              <p className="text-xs text-muted-foreground">
                {metrics.overdueInvoices} overdue items
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Tax Alerts */}
        <Card className="mb-8">
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <AlertCircle className="h-5 w-5 text-warning" />
              <span>Rwanda Tax Compliance Alerts</span>
            </CardTitle>
            <CardDescription>
              Important upcoming deadlines and compliance requirements
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {taxAlerts.map((alert) => (
                <div key={alert.id} className="flex items-center justify-between rounded-lg border border-border p-4">
                  <div className="flex items-center space-x-3">
                    <Badge className={getPriorityColor(alert.priority)}>
                      {alert.priority.toUpperCase()}
                    </Badge>
                    <div>
                      <h4 className="font-medium">{alert.title}</h4>
                      <p className="text-sm text-muted-foreground">{alert.description}</p>
                    </div>
                  </div>
                  <div className="flex items-center space-x-3">
                    <div className="text-right">
                      <p className="text-sm font-medium">Due: {alert.dueDate}</p>
                      <p className="text-xs text-muted-foreground">
                        {alert.type.replace('_', ' ').toUpperCase()}
                      </p>
                    </div>
                    <Button size="sm" variant="outline">
                      <Eye className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Main Content Tabs */}
        <Tabs defaultValue="transactions" className="space-y-4">
          <TabsList>
            <TabsTrigger value="transactions">Recent Transactions</TabsTrigger>
            <TabsTrigger value="analytics">Financial Analytics</TabsTrigger>
            <TabsTrigger value="reports">Rwanda Tax Reports</TabsTrigger>
          </TabsList>

          <TabsContent value="transactions" className="space-y-4">
            <Card>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle>Recent Transactions</CardTitle>
                  <div className="flex items-center space-x-2">
                    <Button variant="outline" size="sm">
                      <Filter className="mr-2 h-4 w-4" />
                      Filter
                    </Button>
                    <Button variant="outline" size="sm">
                      View All
                    </Button>
                  </div>
                </div>
                <CardDescription>
                  Latest financial transactions with VAT and WHT calculations
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {recentTransactions.map((transaction) => (
                    <div key={transaction.id} className="flex items-center justify-between rounded-lg border border-border p-4">
                      <div className="flex items-center space-x-4">
                        <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-muted">
                          {transaction.type === "invoice" && <FileText className="h-5 w-5" />}
                          {transaction.type === "payment" && <DollarSign className="h-5 w-5" />}
                          {transaction.type === "expense" && <Receipt className="h-5 w-5" />}
                        </div>
                        <div>
                          <h4 className="font-medium">{transaction.description}</h4>
                          <div className="flex items-center space-x-2 text-sm text-muted-foreground">
                            <span>{transaction.id}</span>
                            <span>•</span>
                            <span>{transaction.date}</span>
                            {transaction.vatAmount && (
                              <>
                                <span>•</span>
                                <span>VAT: {formatRWF(transaction.vatAmount)}</span>
                              </>
                            )}
                            {transaction.whtAmount && (
                              <>
                                <span>•</span>
                                <span>WHT: {formatRWF(transaction.whtAmount)}</span>
                              </>
                            )}
                          </div>
                        </div>
                      </div>
                      <div className="flex items-center space-x-3">
                        <div className="text-right">
                          <p className="font-medium">{formatRWF(transaction.amount)}</p>
                          <Badge className={getStatusColor(transaction.status)}>
                            {transaction.status}
                          </Badge>
                        </div>
                        <Button size="sm" variant="ghost">
                          <Eye className="h-4 w-4" />
                        </Button>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="analytics" className="space-y-4">
            <div className="grid gap-4 md:grid-cols-2">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center space-x-2">
                    <PieChart className="h-5 w-5" />
                    <span>Revenue by Entity</span>
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="h-48 flex items-center justify-center text-muted-foreground">
                    Revenue distribution chart placeholder
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center space-x-2">
                    <BarChart3 className="h-5 w-5" />
                    <span>Monthly Tax Obligations</span>
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="h-48 flex items-center justify-center text-muted-foreground">
                    Tax obligations trend chart placeholder
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>

          <TabsContent value="reports" className="space-y-4">
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
              <Card className="cursor-pointer hover:shadow-md transition-shadow">
                <CardHeader>
                  <CardTitle className="text-lg">VAT Return</CardTitle>
                  <CardDescription>Generate monthly/quarterly VAT returns for RRA submission</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Next Due: Jan 15, 2024</p>
                      <p className="text-sm font-medium">Amount: {formatRWF(87345000)}</p>
                    </div>
                    <Button size="sm">Generate</Button>
                  </div>
                </CardContent>
              </Card>

              <Card className="cursor-pointer hover:shadow-md transition-shadow">
                <CardHeader>
                  <CardTitle className="text-lg">PAYE Summary</CardTitle>
                  <CardDescription>Employee payroll tax summary for RRA filing</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Next Due: Jan 20, 2024</p>
                      <p className="text-sm font-medium">147 employees</p>
                    </div>
                    <Button size="sm">Generate</Button>
                  </div>
                </CardContent>
              </Card>

              <Card className="cursor-pointer hover:shadow-md transition-shadow">
                <CardHeader>
                  <CardTitle className="text-lg">WHT Register</CardTitle>
                  <CardDescription>Withholding tax register and certificate generation</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Q4 2023</p>
                      <p className="text-sm font-medium">45 certificates</p>
                    </div>
                    <Button size="sm">Generate</Button>
                  </div>
                </CardContent>
              </Card>

              <Card className="cursor-pointer hover:shadow-md transition-shadow">
                <CardHeader>
                  <CardTitle className="text-lg">Balance Sheet</CardTitle>
                  <CardDescription>Financial position statement with multi-entity support</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">As of Dec 31, 2023</p>
                      <p className="text-sm font-medium">All entities</p>
                    </div>
                    <Button size="sm">Generate</Button>
                  </div>
                </CardContent>
              </Card>

              <Card className="cursor-pointer hover:shadow-md transition-shadow">
                <CardHeader>
                  <CardTitle className="text-lg">P&L Statement</CardTitle>
                  <CardDescription>Profit and loss statement with tax details</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">YTD 2023</p>
                      <p className="text-sm font-medium">Multi-currency</p>
                    </div>
                    <Button size="sm">Generate</Button>
                  </div>
                </CardContent>
              </Card>

              <Card className="cursor-pointer hover:shadow-md transition-shadow">
                <CardHeader>
                  <CardTitle className="text-lg">CIT Filing Pack</CardTitle>
                  <CardDescription>Corporate income tax annual filing documents</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Due: Mar 31, 2024</p>
                      <p className="text-sm font-medium">Tax year 2023</p>
                    </div>
                    <Button size="sm">Generate</Button>
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}
