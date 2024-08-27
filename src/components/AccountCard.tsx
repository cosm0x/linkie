"use client";
import { useAccount } from "wagmi";
import axios from "axios";
import { useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import Link from "next/link";

const AccountCard = () => {
  const { address, isConnecting } = useAccount();

  const getTotalPayments = async () => {
    const { data } = await axios.get(`/api/user/${address}/total-payments`);
    return data;
  };

  const { isPending: isLoading, data: total } = useQuery({
    queryKey: ["user", address],
    queryFn: getTotalPayments,
    enabled: !!address,
  });

  return (
    <Card>
      <div className="flex justify-between items-center">
        <div>
          <CardHeader className="pb-2">
            <CardTitle className="text-4xl">${total}</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-xs text-muted-foreground lg:text-sm">
              +received so far
            </div>
          </CardContent>
        </div>

        <Link
          href="/listings/create"
          className="w-fit px-4 mr-4 rounded-md py-2 bg-primary text-primary-foreground shadow hover:bg-primary/90 leading-none"
        >
          + New Listing
        </Link>
      </div>
    </Card>
  );
};
export default AccountCard;
